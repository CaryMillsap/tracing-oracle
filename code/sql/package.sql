-- package to make it easy to instrument and trace

-- Copyright (c) 2022 Method R Corporation

connect system/oracle

drop user mr cascade;
create user mr identified by mr;
grant create session to mr;
grant create procedure to mr;
grant alter session to mr;

drop user cary cascade;
create user cary identified by cary;
grant create session to cary;

connect mr/mr



create or replace package dev_trace as
	procedure trace_begin	(binds in boolean default false, plans in varchar2 default null, statistics_level in varchar2 default 'typical');
	procedure trace_end		;

	procedure set_module	(module in varchar2, action in varchar2);
	procedure set_action	(action in varchar2);
	procedure set_client	(client in varchar2);
	
	procedure get_module	(module out varchar2, action out varchar2);
	procedure get_action	(action out varchar2);
	procedure get_client	(client out varchar2);
	procedure get_filename	(filename out varchar2);

end dev_trace;
/



create or replace package body dev_trace as

	procedure trace_begin(binds in boolean default false, plans in varchar2 default null, statistics_level in varchar2 default 'typical') as
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

	procedure set_module(module in varchar2, action in varchar2) as
	begin
		dbms_application_info.set_module(module_name=>module, action_name=>action);
	end;

	procedure set_action(action in varchar2) as
	begin
		dbms_application_info.set_action(action_name=>action);
	end;

	procedure set_client(client in varchar2) as
	begin
		dbms_session.set_identifier(client_id=>client);
	end;

	procedure get_module(module out varchar2, action out varchar2) as
	begin
		dbms_application_info.read_module(module_name=>module, action_name=>action);
	end;

	procedure get_action(action out varchar2) as
	begin
		action := sys_context('userenv','action');
	end;

	procedure get_client(client out varchar2) as
	begin
		client := sys_context('userenv','client_identifier');
	end;

	procedure get_filename	(filename out varchar2) as
	begin
		select value into filename from v$diag_info where name='Default Trace File';
	end;

end dev_trace;
/
show errors


/*
create or replace package methodr.dba_trace as
	procedure session_on	(sid in number default null, serial in number default null, 													binds in boolean default false, plans in varchar2 default null);
	procedure client_on		(client  in varchar2,																							binds in boolean default false, plans in varchar2 default null);
	procedure sma_on		(service in varchar2, module in varchar2 default '###ALL_MODULES', action in varchar2 default '###ALL_ACTIONS',	binds in boolean default false, plans in varchar2 default null, instance in varchar2 default null);
	procedure database_on	(																												binds in boolean default false, plans in varchar2 default null, instance in varchar2 default null);

	procedure session_off	(sid in number default null, serial in number default null);
	procedure client_off	(client in varchar2);
	procedure sma_off		(service in varchar2, module in varchar2, action in varchar2 default '###ALL_ACTIONS', instance in varchar2 default null);
	procedure database_off	(instance in varchar2 default null);
end dba_trace;
/
show errors
*/



grant execute on dev_trace to cary;

connect cary/cary

