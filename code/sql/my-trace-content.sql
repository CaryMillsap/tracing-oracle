-- print my trace content

-- Copyright (c) 2019, 2022 Method R Corporation

select trim(trailing chr(10) from payload) "TRACE"
from v$diag_trace_file_contents
where adr_home || '/trace/' || trace_filename = (
   select value from v$diag_info where name = 'Default Trace File'
)
order by line_number
/

