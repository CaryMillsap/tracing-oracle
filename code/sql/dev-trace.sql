-- bundle the trace features that a developer needs

-- Copyright (c) 2022, 2023 Method R Corporation

-- connect system/oracle

set termout on
set echo off
set autoprint off
set feedback on

-- User mr will own the package.
drop user mr cascade;
create user mr identified by mr;
grant create session to mr;
grant create procedure to mr;
grant alter session to mr;

-- User dev represents an application developer.
drop user dev cascade;
create user dev identified by dev;
grant create session to dev;


connect mr/mr

create or replace package dev_trace authid definer as

	procedure trace_begin	(binds in boolean default false, plans in varchar2 default null, statistics_level in varchar2 default 'typical');
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
		  binds in boolean default false
		, plans in varchar2 default null
		, statistics_level in varchar2 default 'typical'
	) as
		b varchar2( 5) := case binds when true then 'true' else 'false' end;
		p varchar2(15) := case when plans is null then 'first_execution' else plans end;
	begin
		execute immediate 'alter session set statistics_level='||statistics_level;
		execute immediate 'alter session set max_dump_file_size=unlimited';
		execute immediate 'alter session set events ''sql_trace wait=true,bind='||b||',plan_stat='||p||'''';
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


grant execute on dev_trace to dev;
-- User dev does not require ALTER SESSION system privilege.



/*
The following examples show mr.dev-trace in use.
 */

connect dev/dev

set echo on
set autoprint on
set feedback off

exec mr.dev_trace.set_module('my-module')
exec mr.dev_trace.set_action('my-action')
exec mr.dev_trace.set_client('my-client')

exec mr.dev_trace.trace_begin
select 'my business function goes here' from dual;
exec mr.dev_trace.trace_end

var value varchar2(80)
exec :value := mr.dev_trace.get_service
exec :value := mr.dev_trace.get_module
exec :value := mr.dev_trace.get_action
exec :value := mr.dev_trace.get_client
exec :value := mr.dev_trace.get_filename

