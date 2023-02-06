-- demonstrate the permissions a DBA needs for tracing

-- You must be SYSDBA to perform the required grants.
connect system/oracle as sysdba

drop user dba1 cascade;
grant connect to dba1 identified by "Y0ur-Password-G0es-Here";
grant create session to dba1;

grant execute on sys.dbms_session to dba1;				-- Required to use dbms_session
grant execute on sys.dbms_monitor to dba1;				-- Required to set traces for third-party sessions and handle attributes
-- grant read on sys.v_$diag_info to dba1;				-- Not required, but symmetrical
grant read on sys.v_$diag_trace_file to dba1;			-- Required to read trace file metadata
grant read on sys.v_$diag_trace_file_contents to dba1;	-- Required to read trace file content
grant alter session to dba1;							-- Required to use dbms_session.session_trace_enable (authid current_user)


-- Connect for testing...
connect dba1/Y0ur-Password-G0es-Here

-- Ensure that the required fixed views are accessible 
desc v$diag_info
desc v$diag_trace_file
desc v$diag_trace_file_contents

-- Full cycle: trace an application and access its content.
@trace-on
select 'testing!' from dual;
@trace-off
@my-trace-dir
@my-trace-file
@my-trace-content

