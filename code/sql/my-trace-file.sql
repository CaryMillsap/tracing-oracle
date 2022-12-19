-- print my trace file name

select value "TRACE FILE"
from v$diag_info
where name = 'Default Trace File'
/

exec dbms_session.set_sql_trace(true)
select 'Hi, Cary here...' from dual;
exec dbms_session.set_sql_trace(false)


select trim(trailing chr(10) from payload)
from v$diag_trace_file_contents
where adr_home || '/trace/' || trace_filename = (
	select tracefile
	from v$process
	where addr = (
		select paddr
		from v$session
		where sid = sys_context('userenv', 'sid')
	)
)
order by line_number 
/

select * from session_cloud_trace order by row_number;
desc session_cloud_trace
desc v$diag_trace_file_contents

create or replace directory MMMM as '/u02/app/oracle/diag/rdbms/fehu1pod/fehu1pod1/trace/';

