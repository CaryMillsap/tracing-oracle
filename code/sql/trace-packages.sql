-- bundle the trace features that a developer or DBA needs

-- WARNING: Nothing in this script will work on Oracle Autonomous Database,
-- where Oracle have intentionally prohibited any session from using ALTER
-- SESSION SET EVENTS either directly or indirectly, such as by attempting to
-- execute DBMS_SESSION.SESSION_TRACE_ENABLE.

-- Copyright (c) 2022, 2023 Method R Corporation

connect system/oracle as sysdba

show user

set termout on
set echo off
set autoprint off
set feedback on

-- User MR will own the packages.
drop user mr cascade;
create user mr identified by mr;
grant create session to mr;
grant create procedure to mr;
grant alter session to mr;
grant execute on dbms_application_info to mr;
grant execute on dbms_monitor to mr;

-- User DEV represents an application developer.
drop user dev1 cascade;
create user dev1 identified by dev1;
grant create session to dev1;

-- User DBADMIN represents a database administrator.
drop user dba1 cascade;
create user dba1 identified by dba1;
grant create session to dba1;
grant alter session to dba1;		-- Necessary for DBMS_MONITOR, DBMS_SESSION



-- Create the trace package for application developers.

connect mr/mr

create or replace package dev_trace authid definer as

	procedure trace_begin	(binds in boolean default false, plans in varchar2 default 'first_execution', statistics_level in varchar2 default 'typical');
	procedure trace_end		;

	procedure set_module	(module in varchar2 default null);
	procedure set_action	(action in varchar2 default null);
	procedure set_client	(client in varchar2 default null);
	
	function get_service	return varchar2;
	function get_module		return varchar2;
	function get_action		return varchar2;
	function get_client		return varchar2;
	function get_filename	return varchar2;

end dev_trace;
/


create or replace package body dev_trace as

	procedure trace_begin(
		  binds				in boolean	default false
		, plans				in varchar2	default 'first_execution'
		, statistics_level	in varchar2	default 'typical'
	) as
		b varchar2( 5) := case binds when true then 'true' else 'false' end;
		-- p varchar2(15) := case when plans is null then 'first_execution' else plans end;
	begin
		execute immediate 'alter session set statistics_level='||statistics_level;
		execute immediate 'alter session set max_dump_file_size=unlimited';
		execute immediate 'alter session set events ''sql_trace wait=true,bind='||b||',plan_stat='||plans||'''';
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

create or replace package mr.dba_trace authid definer as

	procedure session_on	(sid in number default null, serial in number default null, 													binds in boolean default false, plans in varchar2 default 'first_execution');
	procedure client_on		(client  in varchar2,																							binds in boolean default false, plans in varchar2 default 'first_execution');
	procedure sma_on		(service in varchar2, module in varchar2 default '###ALL_MODULES', action in varchar2 default '###ALL_ACTIONS',	binds in boolean default false, plans in varchar2 default 'first_execution', instance in varchar2 default null);
	procedure database_on	(																												binds in boolean default false, plans in varchar2 default 'first_execution', instance in varchar2 default null);

	procedure session_off	(sid in number default null, serial in number default null);
	procedure client_off	(client in varchar2);
	procedure sma_off		(service in varchar2, module in varchar2, action in varchar2 default '###ALL_ACTIONS', instance in varchar2 default null);
	procedure database_off	(instance in varchar2 default null);

end dba_trace;
/


create or replace package body mr.dba_trace  as

	procedure session_on(
		  sid		in number	default null
		, serial	in number	default null
		, binds		in boolean	default false
		, plans		in varchar2	default 'first_execution'
	) as
	begin
		dbms_monitor.session_trace_enable(
			  session_id	=> sid
			, serial_num	=> serial
			, waits			=> true
			, binds			=> binds
			, plan_stat		=> plans
		);
	end;

	procedure client_on(
		  client	in varchar2
		, binds		in boolean	default false
		, plans		in varchar2	default 'first_execution'
	) as
	begin
		dbms_monitor.client_id_trace_enable(
			  client_id	=> client
			, waits		=> true
			, binds		=> binds
			, plan_stat	=> plans
		);
	end;

	procedure sma_on(
		  service	in varchar2
		, module	in varchar2	default '###ALL_MODULES'
		, action	in varchar2	default '###ALL_ACTIONS'
		, binds		in boolean	default false
		, plans		in varchar2	default 'first_execution'
		, instance	in varchar2	default null
	) as
	begin
		dbms_monitor.serv_mod_act_trace_enable(
			  service_name	=> service
			, module_name	=> module
			, action_name	=> action
			, waits			=> true
			, binds			=> true
			, instance_name	=> instance
			, plan_stat		=> plans
		);
	end;

	procedure database_on(
		  binds		in boolean	default false
		, plans		in varchar2	default 'first_execution'
		, instance	in varchar2	default null
	) as
	begin
		dbms_monitor.database_trace_enable(
			  waits			=> true
			, binds			=> true
			, instance_name	=> instance
			, plan_stat		=> plans
		);
	end;

	procedure session_off(
		  sid		in number default null
		, serial	in number default null
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
	  	  service	in varchar2
		, module	in varchar2
		, action	in varchar2 default '###ALL_ACTIONS'
		, instance	in varchar2 default null
	) as
	begin
		dbms_monitor.serv_mod_act_trace_disable(
			  service_name	=> service
			, module_name	=> module
			, action_name	=> action
			, instance_name	=> instance
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

grant execute on dev_trace to dev1;
-- User dev1 does not require ALTER SESSION system privilege.

grant execute on dev_trace to dba1;
grant execute on dba_trace to dba1;



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




