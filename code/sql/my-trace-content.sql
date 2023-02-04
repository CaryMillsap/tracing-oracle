-- print trace content

-- Copyright (c) 2019, 2022 Method R Corporation

select trim(trailing chr(10) from payload) "TRACE LINES"
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
