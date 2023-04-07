-- create user MR with appropriate permissions

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba

drop user method_r cascade;                        -- Fresh start.
create user method_r;                              -- This user will own the packages.
-- create user method_r identified by method_r;    -- No need to actually connect as METHOD_R.
-- grant create session to method_r;               -- No need to actually connect as METHOD_R.
-- grant create procedure to method_r;             -- We'll create the procedures connected as SYS.

grant execute  on sys.dbms_application_info        to method_r;   -- For setting and getting Oracle user session handle attributes.
grant execute  on sys.dbms_session                 to method_r;   -- Won't use session_trace_(en|dis)able, but will use set_identifier.
grant execute  on sys.dbms_monitor                 to method_r;   -- Trace (en|dis)able procedures.
grant execute  on sys.dbms_assert                  to method_r;   -- To prevent SQL injection.
grant read     on sys.v_$instance                  to method_r;   -- Needed for its data types.
grant read     on sys.v_$session                   to method_r;   -- Needed for its data types.

-- grant read     on sys.v_$diag_info                 to method_r;
-- grant read     on sys.v_$statistics_level          to method_r;

grant read     on sys.v_$diag_trace_file_contents  to method_r;   -- #TODO not used yet

