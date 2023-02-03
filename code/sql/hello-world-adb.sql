-- "hello, world", your first trace (Autonomous Database)

alter session set sql_trace=true;
select 'hello, world' from dual;
alter session set sql_trace=false;

@my-adb-trace-contents

