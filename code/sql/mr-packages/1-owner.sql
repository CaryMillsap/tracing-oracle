-- create user MR with appropriate permissions

-- Copyright (c) 2022, 2023 Method R Corporation


connect sys/oracle as sysdba

-- User MR (Method R) will own the packages.
drop user mr cascade;                  -- Fresh start
create user mr;
-- create user mr identified by mr;    -- No need to actually connect as MR
-- grant create session to mr;
-- grant create procedure to mr;
-- grant alter session to mr;          -- Required if you want to use dbms_session.session_trace_enable.
grant execute  on sys.dbms_application_info        to mr;
grant execute  on sys.dbms_session                 to mr;      -- Required to use set_identifier
grant execute  on sys.dbms_monitor                 to mr;
grant execute  on sys.dbms_assert                  to mr;
grant read     on sys.dba_enabled_traces           to mr;
grant read     on sys.v_$statistics_level          to mr;
grant read     on sys.v_$diag_info                 to mr;
grant read     on sys.v_$instance                  to mr;
grant read     on sys.v_$session                   to mr;
grant read     on sys.v_$diag_trace_file_contents  to mr;      -- #TODO not used yet


