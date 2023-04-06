-- bundle the trace features that a developer or DBA needs

-- WARNING: Nothing in this script will work in Oracle Autonomous Database on
-- shared infrastructure (ADB-S), where Oracle have intentionally prohibited
-- any session from using DBMS_MONITOR or any form of ALTER SESSION SET EVENTS
-- either directly or indirectly (as DBMS_SESSION.SESSION_TRACE_ENABLE does).

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba

-- User MR (Method R) will own the packages.
drop user mr cascade;                  -- Fresh start
create user mr;
-- create user mr identified by mr;    -- No need to actually connect as MR
-- grant create session to mr;
-- grant create procedure to mr;
-- grant alter session to mr;          -- Required if you want to use dbms_session.session_trace_enable.
grant execute  on sys.dbms_application_info        to mr;
grant execute  on sys.dbms_session                 to mr;      -- Required to use set_identifier
grant execute  on sys.dbms_monitor                 to mr;
grant execute  on sys.dbms_assert                  to mr;
grant read     on sys.dba_enabled_traces           to mr;
grant read     on sys.v_$statistics_level          to mr;
grant read     on sys.v_$diag_info                 to mr;
grant read     on sys.v_$instance                  to mr;
grant read     on sys.v_$session                   to mr;
grant read     on sys.v_$diag_trace_file_contents  to mr;      -- #TODO not used yet



-- Trace package mrdev for application developers.

create or replace package mr.mrdev authid definer as

   procedure trace_on(
        binds  in boolean  default false
      , plans  in varchar2 default 'first_execution'
      , stats  in varchar2 default 'typical'
   );
   procedure trace_off;

   procedure set_module(module in varchar2 default null);
   procedure set_action(action in varchar2 default null);
   procedure set_client(client in varchar2 default null);
   
   function get_service    return varchar2;
   function get_module     return varchar2;
   function get_action     return varchar2;
   function get_client     return varchar2;
   function get_filename   return varchar2;
   -- function get_content return ???;       -- #TODO return what?

end mrdev;
/



create or replace package body mr.mrdev as

   procedure trace_on(
        binds  in boolean  default false
      , plans  in varchar2 default 'first_execution'
      , stats  in varchar2 default 'typical'
   ) as
      s varchar2(64 char) := dbms_assert.simple_sql_name(stats);
   begin
      execute immediate q'[alter session set max_dump_file_size=unlimited]';
      execute immediate q'[alter session set statistics_level=]'||s;
      dbms_monitor.session_trace_enable(
           waits     => true
         , binds     => binds
         , plan_stat => plans
      );

      -- There are at least three ways we could have enabled tracing.

      -- ALTER SESSION is ugly and unsafe:

         -- execute immediate q'[alter session set events 'sql_trace wait=true,bind=]'||b||q'[,plan_stat=]'||p||q'[']';

      -- DBMS_SESSION sounds like it should be the right package to use, but it
      -- uses invoker's rights, which requires its callers--*anywhere* in the
      -- call stack!--to have the ALTER SESSION system privilege. It's not good
      -- for developers to have ALTER SESSION. 

      -- DBMS_MONITOR is definer's rights and does everything we need, cleanly
      -- and safely.

   end;

   procedure trace_off as
   begin
      dbms_monitor.session_trace_disable;
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

end mrdev;
/

show errors





-- Trace package mrdba for database administrators.

create or replace package mr.mrdba authid definer as

   all_modules    sys.v_$session.module%type          := dbms_monitor.all_modules;
   all_actions    sys.v_$session.action%type          := dbms_monitor.all_actions;
   all_instances  sys.v_$instance.instance_name%type  := null;

   procedure session_on(
        sid       in binary_integer default null
      , serial    in binary_integer default null
      , binds     in boolean        default false
      , plans     in varchar2       default 'first_execution'
   );
   procedure client_on(
        client    in varchar2
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
   );
   procedure handle_on(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default all_modules
      , action    in varchar2 default all_actions
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default all_instances
   );
   procedure database_on(
        binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default all_instances
   );

   procedure session_off(
        sid       in binary_integer default null
      , serial    in binary_integer default null
   );
   procedure client_off(
        client    in varchar2
   );
   procedure handle_off(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default all_modules
      , action    in varchar2 default all_actions
      , instance  in varchar2 default all_instances
   );
   procedure database_off(
        instance in varchar2 default all_instances
   );

end mrdba;
/


create or replace package body mr.mrdba  as

   procedure session_on(
        sid       in binary_integer default null
      , serial    in binary_integer default null
      , binds     in boolean        default false
      , plans     in varchar2       default 'first_execution'
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

   procedure handle_on(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default all_modules
      , action    in varchar2 default all_actions
      , binds     in boolean  default false
      , plans     in varchar2 default 'first_execution'
      , instance  in varchar2 default all_instances
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
      , instance  in varchar2 default all_instances
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
        sid    in binary_integer default null
      , serial in binary_integer default null
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

   procedure handle_off(
        service   in varchar2 default sys_context('userenv','service_name')
      , module    in varchar2 default all_modules
      , action    in varchar2 default all_actions
      , instance  in varchar2 default all_instances
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
        instance in varchar2 default all_instances
   ) as
   begin
      dbms_monitor.database_trace_disable(
           instance_name => instance
      );
   end;

end mrdba;
/

show errors


