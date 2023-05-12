-- test MR packages and privileges


-- You must be SYSDBA to perform the required grants.
connect sys/oracle@orcl as sysdba


-- User DEV1 represents an application developer.
drop user dev1 cascade;                                     -- Fresh start
create user dev1 identified by "Your-password-g0es-here";   -- An application developer
grant create session to dev1;
grant mr_developer_role to dev1;                            -- Endow the developer with Method R privileges

-- User DBA1 represents a database administrator.
drop user dba1 cascade;                                     -- Fresh start
create user dba1 identified by "Your-password-g0es-here";   -- A database administrator
grant dba to dba1;                                          -- A regular DBA
grant execute on mrdev to dba1;                             -- The Method R developer toolkit
grant execute on mrdba to dba1;                             -- The Method R DBA toolkit


-- Developer testing
connect dev1/Your-password-g0es-here

-- Test the mrdev.set procedures.
exec mrdev.set_module('my-module')
exec mrdev.set_action('my-action')
exec mrdev.set_client('my-client')

-- Test the mrdev.get functions.
set autoprint on
var value varchar2(4000)
exec :value := q'[service=']'  || mrdev.get_service  || q'[']'
exec :value := q'[module=']'   || mrdev.get_module   || q'[']'
exec :value := q'[action=']'   || mrdev.get_action   || q'[']'
exec :value := q'[client=']'   || mrdev.get_client   || q'[']'
exec :value := q'[filename=']' || mrdev.get_filename || q'[']'
set autoprint off

-- Test tracing.
exec mrdev.trace_on
col s new_value s
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') s from dual;         -- Unique timestamp to validate trace file content
select q'[The program I'm writing ran at &s]' message from dual;     -- This is where your application being traced would go
exec mrdev.trace_off
set pagesize 500
@my-trace-content            -- #TODO delete this line when mrdev.get_content is written
-- exec mrdev.get_content    -- #TODO not written yet


-- DBA testing
connect dba1/Your-password-g0es-here

-- Test trace enablers.
@enabled-traces
exec mrdba.handle_on(module=>'cary_module', action=>'cary_action');
@enabled-traces
exec mrdba.handle_off(module=>'cary_module', action=>'cary_action');
@enabled-traces

-- Test tracing.
exec mrdba.session_on;
col s new_value s
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') s from dual;         -- Unique timestamp to validate trace file content
select q'[The program I'm diagnosing ran at &s]' message from dual;  -- This is where your application being traced would go
exec mrdba.session_off;
set pagesize 500
@my-trace-content

