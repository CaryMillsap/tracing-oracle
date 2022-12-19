-- set up the directory object for GetTraceFile
-- © 2021 Method R Corporation

select directory_name from all_directories where directory_path = (select value from v$diag_info where name = 'Diag Trace');

-- If the query returns no rows, then you'll need to create a directory object and grant read privilege on it.
-- #TODO

create or replace directory METHODR_UDUMP_1 as '/u01/app/oracle/diag/rdbms/ora193/ora193/trace'; #TODO
grant read on #TODO to #TODO ;



