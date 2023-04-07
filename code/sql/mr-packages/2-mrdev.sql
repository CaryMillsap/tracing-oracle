-- bundle the trace features that a developer needs

-- WARNING: Nothing in this script will work in Oracle Autonomous Database on
-- shared infrastructure (ADB-S), where Oracle have intentionally prohibited
-- any session from using DBMS_MONITOR or any form of ALTER SESSION SET EVENTS
-- either directly or indirectly (as DBMS_SESSION.SESSION_TRACE_ENABLE does).

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba


create or replace package method_r.mrdev authid definer as

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


create or replace package body method_r.mrdev as

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
      dbms_session.set_identifier(client_id=>client);    -- Bizarre that there's no dbms_application_info.set_identifier.
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


