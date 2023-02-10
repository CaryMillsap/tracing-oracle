-- bundle the trace features that a developer or DBA needs

-- WARNING: Nothing in this script will work on Oracle Autonomous Database,
-- where Oracle have intentionally prohibited any session from using ALTER
-- SESSION SET EVENTS either directly or indirectly, such as by attempting to
-- execute DBMS_SESSION.SESSION_TRACE_ENABLE.

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba

-- User MR (Method R) will own the packages.
drop user mr cascade;                                       -- Fresh start
create user mr;
-- create user mr identified by mr;                         -- No need to actually connect as MR
-- grant create session to mr;
-- grant create procedure to mr;
grant alter session                                to mr;   -- Required to use dbms_session.session_trace_enable
grant execute  on sys.dbms_application_info        to mr;
grant execute  on sys.dbms_session                 to mr;
grant execute  on sys.dbms_monitor                 to mr;
grant read     on sys.dba_enabled_traces           to mr;
grant read     on sys.v_$statistics_level          to mr;
grant read     on sys.v_$diag_info                 to mr;
grant read     on sys.v_$diag_trace_file_contents  to mr;      -- #TODO not used yet


-- Create the trace package for application developers.

create or replace package mr.dev_trace authid definer as

   procedure trace_begin(
        binds  in boolean  default false
      , plans  in varchar2 default 'first_execution'
      , stats  in varchar2 default 'typical'
   );
   procedure trace_end;

   procedure set_module(module in varchar2 default null);
   procedure set_action(action in varchar2 default null);
   procedure set_client(client in varchar2 default null);
   
   function get_service    return varchar2;
   function get_module     return varchar2;
   function get_action     return varchar2;
   function get_client     return varchar2;
   function get_filename   return varchar2;
   -- function get_content return ???;       -- #TODO return what?

end dev_trace;
/


create or replace package body mr.dev_trace as

   procedure trace_begin(
        binds   in boolean  default false
      , plans   in varchar2 default 'first_execution'
      , stats   in varchar2 default 'typical'
   ) as
      b varchar2( 5 char) := case binds when true then 'true' else 'false' end;
      p varchar2(64 char) := dbms_assert.simple_sql_name(plans);
      -- p sys.dba_enabled_traces.plan_stats%type        := dbms_assert.simple_sql_name(plans);
      -- Oracle defect: astonishingly, sys.dba_enabled_traces.plan_stats%type...
      -- 1. is called plan_statS (instead of plan_stat, like the argument)
      -- 2. is big enough to store only the string 'FIRST_EXEC' (and not 'FIRST_EXECUTION')
      s varchar2(64 char) := dbms_assert.simple_sql_name(stats);
      -- s sys.v_$statistics_level.activation_level%type := dbms_assert.simple_sql_name(stats);
      -- Should use the %type specification, but it's hard to trust it after seeing dba_enabled_traces.
   begin
      execute immediate q'[alter session set max_dump_file_size=unlimited]';
      execute immediate q'[alter session set statistics_level=]'||s;
      execute immediate q'[alter session set events 'sql_trace wait=true,bind=]'||b||q'[,plan_stat=]'||p||q'[']';
   end;

   procedure trace_end as
   begin
      execute immediate q'[alter session set events 'sql_trace off']';
   end;

   procedure set_module(
        module in varchar2 default null
   ) as
   begin
      dbms_application_info.set_module(module_name=>module, action_name=>null);
   end;

   procedure set_action(
        action in varchar2 default null
   ) as
   begin
      dbms_application_info.set_action(action_name=>action);
   end;

   procedure set_client(
        client in varchar2 default null
   ) as
   begin
      dbms_session.set_identifier(client_id=>client);    -- Bizarre that it's not dbms_application_info.
   end;

   function get_service return varchar2
   as
   begin
      return sys_context('userenv','service_name');      -- Bizarre that "_name" is in the name.
   end;

   function get_module return varchar2
   as
   begin
      return sys_context('userenv','module');
   end;

   function get_action return varchar2
   as
   begin
      return sys_context('userenv','action');
   end;

   function get_client return varchar2
   as
   begin
      return sys_context('userenv','client_identifier');
   end;

   function get_filename return varchar2
   as
      f sys.v_$diag_info.value%type;
   begin
      select value into f from v$diag_info where name='Default Trace File';
      return f;
   end;

end dev_trace;
/

show errors





-- Trace package for database administrators.

create or replace package mr.dba_trace authid definer as

   procedure session_on(
        sid       in number   default null
      , serial    in number   default null
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
   );
   procedure client_on(
        client    in varchar2
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
   );
   procedure sma_on(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default dbms_monitor.all_modules
      , action    in varchar2 default dbms_monitor.all_actions
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default null
   );
   procedure database_on(
        binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default null
   );

   procedure session_off(
        sid       in number   default null
      , serial    in number   default null
   );
   procedure client_off(
        client    in varchar2
   );
   procedure sma_off(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default dbms_monitor.all_modules
      , action    in varchar2 default dbms_monitor.all_actions
      , instance  in varchar2 default null
   );
   procedure database_off(
        instance in varchar2 default null
   );

end dba_trace;
/


create or replace package body mr.dba_trace  as

   procedure session_on(
        sid       in number   default null
      , serial    in number   default null
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
   ) as
   begin
      dbms_monitor.session_trace_enable(
           session_id   => sid
         , serial_num   => serial
         , waits        => true
         , binds        => binds
         , plan_stat    => plans
      );
   end;

   procedure client_on(
        client    in varchar2
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
   ) as
   begin
      dbms_monitor.client_id_trace_enable(
           client_id => client
         , waits     => true
         , binds     => binds
         , plan_stat => plans
      );
   end;

   procedure sma_on(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default dbms_monitor.all_modules
      , action    in varchar2 default dbms_monitor.all_actions
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default null
   ) as
   begin
      dbms_monitor.serv_mod_act_trace_enable(
           service_name    => service
         , module_name     => module
         , action_name     => action
         , waits           => true
         , binds           => binds
         , instance_name   => instance
         , plan_stat       => plans
      );
   end;

   procedure database_on(
        binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default null
   ) as
   begin
      dbms_monitor.database_trace_enable(
           waits           => true
         , binds           => binds
         , instance_name   => instance
         , plan_stat       => plans
      );
   end;

   procedure session_off(
        sid    in number default null
      , serial in number default null
   ) as
   begin
      dbms_monitor.session_trace_disable(
           session_id => sid
         , serial_num => serial
      );
   end;

   procedure client_off(
        client in varchar2
   ) as
   begin
      dbms_monitor.client_id_trace_disable(
           client_id => client
      );
   end;

   procedure sma_off(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default dbms_monitor.all_modules
      , action    in varchar2 default dbms_monitor.all_actions
      , instance  in varchar2 default null
   ) as
   begin
      dbms_monitor.serv_mod_act_trace_disable(
           service_name    => service
         , module_name     => module
         , action_name     => action
         , instance_name   => instance
      );
   end;

   procedure database_off(
        instance in varchar2 default null
   ) as
   begin
      dbms_monitor.database_trace_disable(
           instance_name => instance
      );
   end;

end dba_trace;
/

show errors


