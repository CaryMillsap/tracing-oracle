-- demonstrate the permissions a developer needs for tracing

-- You must be SYSDBA to perform the required grants.
connect sys/oracle as sysdba

-- Replace "dev1" with the schema name of your developer.
drop user dev1 cascade;									-- Fresh start
create user dev1 identified by "Y0ur-Password-G0es-Here";
grant create session to dev1;

grant execute on sys.dbms_session to dev1;				-- Required to use dbms_session
grant execute on sys.dbms_application_info to dev1;		-- Required to set Oracle user session handle attributes
-- grant read on sys.v_$diag_info to dev1;				-- Not required, but symmetrical
-- grant read on sys.v_$diag_trace_file to dev1;		-- Nice to have, but not used by any tracing-oracle scripts
grant read on sys.v_$diag_trace_file_contents to dev1;	-- Required to read trace file content
grant alter session to dev1;							-- Required to use dbms_session.session_trace_enable (authid current_user)


-- Connect for testing...
connect dev1/Y0ur-Password-G0es-Here

-- -- Test whether the required fixed views are accessible.
-- desc v$diag_info
-- desc v$diag_trace_file
-- desc v$diag_trace_file_contents

-- Full cycle: trace an application and access its content.
@hello-world

