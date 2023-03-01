-- show authid for DBMS_MONOTIR, DBMS_SESSION procedures


select object_name, procedure_name, authid from dba_procedures
where object_name in ('DBMS_MONITOR','DBMS_SESSION')
order by 1,2
/
