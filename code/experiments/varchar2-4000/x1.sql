-- test session_cloud_trace

-- ADMIN
show user

drop user u1 cascade;
grant connect to u1 identified by "ThisIs-00Fun";
grant create session to u1;



conn u1/ThisIs-00Fun

alter session set sql_trace=true;
select 'hello, world' from dual;
alter session set sql_trace=false;

-- ORA-00942
@my-adb-trace-contents

-- SP2-0749
desc session_cloud_trace

