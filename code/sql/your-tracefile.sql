-- print trace file name for SID=&1

select tracefile
from v$process
where addr = (
	select paddr
	from v$session
	where sid=&1
)
/


