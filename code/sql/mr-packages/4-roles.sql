-- create roles and users that a developer needs for tracing


-- You must be SYSDBA to perform the required grants.
connect sys/oracle as sysdba


-- Create public synonyms for method_r.* packages.
drop   public synonym mrdev;
create public synonym mrdev for method_r.mrdev;

drop   public synonym mrdba;
create public synonym mrdba for method_r.mrdba;


-- Create role "mr_developer_role", the Method R-endowed application developer.
drop role mr_developer_role;                    -- Fresh start
create role mr_developer_role;                  -- The Method R-endowed application developer
grant execute on mrdev to mr_developer_role;    -- Helpful tracing features

-- We don't want to add the following privs, because the capabilities they
-- enable are already offered by the MRDEV package.

-- grant execute on sys.dbms_session            to mr_developer_role;   -- Required to use dbms_session
-- grant execute on sys.dbms_application_info   to mr_developer_role;   -- Required to set Oracle user session handle attributes
-- grant read    on sys.v_$diag_info            to mr_developer_role;   -- Not required, but symmetrical
-- grant read    on sys.v_$diag_trace_file      to mr_developer_role;   -- Nice to have, but not used by any tracing-oracle scripts
-- grant alter session                          to mr_developer_role;   -- Required to use dbms_session.session_trace_enable (invoker's rights)

grant read on sys.v_$diag_trace_file_contents to mr_developer_role;     -- Required to read trace file content #TODO remove this when mr.mrdev.get_contents is done




