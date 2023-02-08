-- demonstrate the permissions a developer needs for tracing

-- You must be SYSDBA to perform the required grants.
connect sys/oracle as sysdba

-- Create role "mrdev", the Method R-endowed application developer.
drop role mrdev;                                            -- Fresh start
create role mrdev;                                          -- The Method R-endowed application developer
   grant execute on sys.dbms_session to mrdev;              -- Required to use dbms_session
   grant execute on sys.dbms_application_info to mrdev;     -- Required to set Oracle user session handle attributes
   -- grant read on sys.v_$diag_info to mrdev;              -- Not required, but symmetrical
   -- grant read on sys.v_$diag_trace_file to mrdev;        -- Nice to have, but not used by any tracing-oracle scripts
   grant read on sys.v_$diag_trace_file_contents to mrdev;  -- Required to read trace file content
   grant alter session to mrdev;                            -- Required to use dbms_session.session_trace_enable (authid current_user)

-- Replace "dev1" with the schema name of your developer.
drop user dev1 cascade;                                     -- Fresh start
create user dev1 identified by "Y0ur-Password-G0es-Here";   -- An application developer
grant create session to dev1;
grant mrdev to dev1;                                        -- Endow the developer with Method R privileges

-- Connect for testing...
connect dev1/Y0ur-Password-G0es-Here

-- -- Test whether the required fixed views are accessible.
-- desc v$diag_info
-- desc v$diag_trace_file
-- desc v$diag_trace_file_contents

-- Trace an application and view the trace content.
@hello-world

