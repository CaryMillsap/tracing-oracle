-- create a .sql file that will fetch trace files

set pagesize 0
set linesize 500
set trimspool on
set feedback off
set echo off

!mkdir traces
spool traces/fetch-traces.sql

prompt -- Generated by spool-trace-fetches.sql
prompt set pagesize 0
prompt set linesize 500
prompt set trimspool on
prompt set feedback off
prompt set echo off
 
select distinct 'spool traces/' || trace_filename || chr(10) ||
   '
      select trim(trailing chr(10) from payload) trace 
      from v$diag_trace_file_contents
      where trace_filename  = ''' || trace_filename  || '''
      order by line_number;
   ' || chr(10) command
from v$diag_trace_file_contents
-- where trace_filename = 'orclcdb_ora_9622.trc'  -- #TODO Your filter goes here.
/

prompt spool off
spool off

set termout off
@traces/fetch-traces.sql
set termout on


