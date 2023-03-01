-- show authid for DBMS_MONOTIR, DBMS_SESSION procedures

-- Thanks to petefinnigan.com.

select owner
   , object_name
   , procedure_name
   , object_type
   , authid 
from dba_procedures
where object_name in ('DBMS_MONITOR','DBMS_SESSION')
order by 1,2,3
/
