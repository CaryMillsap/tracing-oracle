-- demonstrate the privileges a developer needs for tracing


-- You must be SYSDBA to perform the required grants.
connect sys/oracle as sysdba


-- Create role "mrdev", the Method R-endowed application developer.
drop role mrdev;                                            -- Fresh start
create role mrdev;                                          -- The Method R-endowed application developer
   grant execute on mr.mrdev to mrdev;                      -- Helpful tracing features
   -- grant execute on sys.dbms_session to mrdev;           -- Required to use dbms_session
   -- grant execute on sys.dbms_application_info to mrdev;  -- Required to set Oracle user session handle attributes
   -- grant read on sys.v_$diag_info to mrdev;              -- Not required, but symmetrical
   -- grant read on sys.v_$diag_trace_file to mrdev;        -- Nice to have, but not used by any tracing-oracle scripts
   -- grant alter session to mrdev;                         -- Required to use dbms_session.session_trace_enable (invoker's rights)
   grant read on sys.v_$diag_trace_file_contents to mrdev;  -- Required to read trace file content #TODO remove this when mr.mrdev.get_contents is done


-- User DEV1 represents an application developer.
drop user dev1 cascade;                                     -- Fresh start
create user dev1 identified by "Your-password-g0es-here";   -- An application developer
grant create session to dev1;
grant mrdev to dev1;                                        -- Endow the developer with Method R privileges


-- User DBA1 represents a database administrator.
drop user dba1 cascade;                                     -- Fresh start
create user dba1 identified by "Your-password-g0es-here";   -- A database administrator
grant dba to dba1;                                          -- A regular DBA
grant execute on mr.mrdev to dba1;                          -- The Method R developer toolkit
grant execute on mr.mrdba to dba1;                          -- The Method R DBA toolkit




-- Developer testing
connect dev1/Your-password-g0es-here

-- Test the mr.mrdev.set procedures.
exec mr.mrdev.set_module('my-module')
exec mr.mrdev.set_action('my-action')
exec mr.mrdev.set_client('my-client')

-- Test the mr.mrdev.get functions.
set autoprint on
var value varchar2(4000)
exec :value := q'[service=']'  || mr.mrdev.get_service  || q'[']'
exec :value := q'[module=']'   || mr.mrdev.get_module   || q'[']'
exec :value := q'[action=']'   || mr.mrdev.get_action   || q'[']'
exec :value := q'[client=']'   || mr.mrdev.get_client   || q'[']'
exec :value := q'[filename=']' || mr.mrdev.get_filename || q'[']'
set autoprint off

-- Test tracing.
exec mr.mrdev.trace_on
col s new_value s
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') s from dual;         -- Unique timestamp to validate trace file content
select q'[The program I'm writing ran at &s]' message from dual;     -- This is where your application being traced would go
exec mr.mrdev.trace_off
set pagesize 500
@my-trace-content               -- #TODO delete this line when mr.mrdev.get_content is written
-- exec mr.mrdev.get_content    -- #TODO not written yet



-- DBA testing
connect dba1/Your-password-g0es-here

-- Test trace enablers.
@enabled-traces
exec mr.mrdba.handle_on(module=>'cary_module', action=>'cary_action');
@enabled-traces
exec mr.mrdba.handle_off(module=>'cary_module', action=>'cary_action');
@enabled-traces

-- Test tracing.
exec mr.mrdba.session_on;
col s new_value s
select to_char(sysdate,'YYYY-MM-DD HH24:MI:SS') s from dual;         -- Unique timestamp to validate trace file content
select q'[The program I'm diagnosing ran at &s]' message from dual;  -- This is where your application being traced would go
exec mr.mrdba.session_off;
set pagesize 500
@my-trace-content

