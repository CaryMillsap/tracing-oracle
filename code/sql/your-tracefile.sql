-- print trace file name for sid=&1

select tracefile
from v$process
where addr = (
	select paddr
	from v$session
	where sid=&1
)
/


