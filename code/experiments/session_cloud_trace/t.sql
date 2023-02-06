-- test session_cloud_trace


connect admin
drop user u1 cascade;
grant connect to u1 identified by "???";
grant create session to u1;
grant read on session_cloud_trace to u1;

connect u1
alter session set sql_trace=true;
select 'hello, world' from dual;
alter session set sql_trace=false;
@adb/my-trace-contents

