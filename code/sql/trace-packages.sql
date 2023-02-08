-- bundle the trace features that a developer or DBA needs

-- WARNING: Nothing in this script will work on Oracle Autonomous Database,
-- where Oracle have intentionally prohibited any session from using ALTER
-- SESSION SET EVENTS either directly or indirectly, such as by attempting to
-- execute DBMS_SESSION.SESSION_TRACE_ENABLE.

-- Copyright (c) 2022, 2023 Method R Corporation

connect sys/oracle as sysdba

show user

set termout on
set echo off
set autoprint off
set feedback on

-- User MR will own the packages.
drop user mr cascade;
create user mr;
grant create session to mr;
grant alter session to mr;
grant create procedure to mr;
grant execute on sys.dbms_application_info to mr;
grant execute on sys.dbms_monitor to mr;

-- User DEV1 represents an application developer.
drop user dev1 cascade;
create user dev1 identified by dev1;
grant create session to dev1;

-- User DBA1 represents a database administrator.
drop user dba1 cascade;
create user dba1 identified by dba1;
grant dba to dba1;



-- Create the trace package for application developers.

create or replace package mr.dev_trace authid definer as

   procedure trace_begin   (binds in boolean default false, plans in varchar2 default 'first_execution', statistics_level in varchar2 default 'typical');
   procedure trace_end     ;

   procedure set_module (module in varchar2 default null);
   procedure set_action (action in varchar2 default null);
   procedure set_client (client in varchar2 default null);
   
   function get_service    return varchar2;
   function get_module     return varchar2;
   function get_action     return varchar2;
   function get_client     return varchar2;
   function get_filename   return varchar2;

end dev_trace;
/


create or replace package body mr.dev_trace as

   procedure trace_begin(
        binds              in boolean  default false
      , plans              in varchar2 default 'first_execution'
      , statistics_level   in varchar2 default 'typical'
   ) as
      b varchar2(5 char) := case binds when true then 'true' else 'false' end;
      p dba_enabled_traces.plan_stats%type       := dbms_assert.qualified_sql_name(plans);
      s v$statistics_level.activation_level%type := dbms_assert.qualified_sql_name(statistics_level);
   begin
      execute immediate 'alter session set statistics_level='||s;
      execute immediate 'alter session set max_dump_file_size=unlimited';
      execute immediate q'[alter session set events 'sql_trace wait=true,bind=]'||b||',plan_stat='||p||q'[']';
   end;

   procedure trace_end as
   begin
      execute immediate 'alter session set events ''sql_trace off''';
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
      dbms_session.set_identifier(client_id=>client);
   end;

   function get_service return varchar2
   as
   begin
      return sys_context('userenv','service_name');
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
      f varchar2(1024);
   begin
      select value into f from v$diag_info where name='Default Trace File';
      return f;
   end;

end dev_trace;
/
show errors





-- Trace package for database administrators.

-- #TODO Should I have an instance arg in the sesion_on and client_on procedures?

create or replace package mr.dba_trace authid definer as

   procedure session_on    (sid in number default null, serial in number default null,                                                       binds in boolean default false, plans in varchar2 default 'first_execution');
   procedure client_on     (client  in varchar2,                                                                                             binds in boolean default false, plans in varchar2 default 'first_execution');
   procedure sma_on        (service in varchar2, module in varchar2 default '###ALL_MODULES', action in varchar2 default '###ALL_ACTIONS',   binds in boolean default false, plans in varchar2 default 'first_execution', instance in varchar2 default null);
   procedure database_on   (                                                                                                                 binds in boolean default false, plans in varchar2 default 'first_execution', instance in varchar2 default null);

   procedure session_off   (sid in number default null, serial in number default null);
   procedure client_off    (client in varchar2);
   procedure sma_off       (service in varchar2, module in varchar2, action in varchar2 default '###ALL_ACTIONS', instance in varchar2 default null);
   procedure database_off  (instance in varchar2 default null);

end dba_trace;
/


create or replace package body mr.dba_trace  as

   procedure session_on(
        sid    in number   default null
      , serial in number   default null
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
        client in varchar2
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
        service   in varchar2
      , module    in varchar2 default '###ALL_MODULES'
      , action    in varchar2 default '###ALL_ACTIONS'
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
         , binds           => true
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
         , binds           => true
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
        service   in varchar2
      , module    in varchar2
      , action    in varchar2 default '###ALL_ACTIONS'
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



-- Privileges.

grant execute on mr.dev_trace to dev1;
-- User dev1 does not require ALTER SESSION system privilege.

grant execute on mr.dev_trace to dba1;
grant execute on mr.dba_trace to dba1;



-- The following examples show mr.dev-trace in use.

connect dev1/dev1

set echo on
set autoprint on
set feedback off

exec mr.dev_trace.set_module('my-module')
exec mr.dev_trace.set_action('my-action')
exec mr.dev_trace.set_client('my-client')

exec mr.dev_trace.trace_begin
select 'my business function goes here' message from dual;
exec mr.dev_trace.trace_end

var value varchar2(80)
exec :value := mr.dev_trace.get_service
exec :value := mr.dev_trace.get_module
exec :value := mr.dev_trace.get_action
exec :value := mr.dev_trace.get_client
exec :value := mr.dev_trace.get_filename



-- The following examples show mr.dba-trace in use.

connect dba1/dba1

set echo on
set autoprint on
set feedback off

exec mr.dba_trace.session_on;
select 'my program to diagnose goes here' message from dual;
exec mr.dba_trace.session_off;
exec :value := mr.dev_trace.get_filename;




