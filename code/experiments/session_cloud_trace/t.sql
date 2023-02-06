-- demonstrate the permissions required for tracing (ADB)


connect admin

drop user u1 cascade;
grant connect to u1 identified by "Y0ur-Password-G0es-Here";
grant create session to u1;

grant alter session to u1;
grant read on session_cloud_trace to u1;

-- Test with the following...
connect u1/Y0ur-Password-G0es-Here
alter session set sql_trace=true;
select 'hello, world' from dual;
alter session set sql_trace=false;
@adb/my-trace-content

