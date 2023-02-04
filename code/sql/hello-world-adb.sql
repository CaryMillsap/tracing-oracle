-- "hello, world", your first trace (Autonomous mix)

/*

This script will ONLY run on an Oracle Autonomous Database system.

If you cannot connect as ADMIN, then you'll need ADMIN to grant the following:

    grant read on session_cloud trace to USERNAME

*/

connect admin

alter session set sql_trace=true;
select 'hello, world' from dual;
alter session set sql_trace=false;

@my-adb-trace-content

