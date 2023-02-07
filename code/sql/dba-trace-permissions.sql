-- demonstrate the permissions a DBA needs for tracing

-- You must be SYSDBA to perform the required grants.
connect sys/oracle as sysdba

-- Replace "dba1" with the schema name of your DBA.
drop user dba1 cascade;                                 -- Fresh start
grant connect to dba1 identified by "Y0ur-Password-G0es-Here";
grant dba to dba1;

-- Connect for testing...
connect dba1/Y0ur-Password-G0es-Here

-- Full cycle: trace an application and access its content.
@trace-on
select 'testing!' from dual;
@trace-off
@my-trace-dir
@my-trace-file
@my-trace-content

