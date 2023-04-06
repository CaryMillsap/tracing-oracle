-- bundle the trace features that a DBA needs

-- WARNING: Nothing in this script will work in Oracle Autonomous Database on
-- shared infrastructure (ADB-S), where Oracle have intentionally prohibited
-- any session from using DBMS_MONITOR or any form of ALTER SESSION SET EVENTS
-- either directly or indirectly (as DBMS_SESSION.SESSION_TRACE_ENABLE does).

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba


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


