-- "hello, world", your first trace

/*
  This script will NOT run on an Oracle Autonomous Database system.

  If you can connect as SYSTEM, then you won't need any additional grants to
  run this script. Otherwise, if you connect as USERNAME, you'll need a DBA to
  grant the following:

    grant execute on dbms_session to USERNAME
    grant alter session to USERNAME

*/

connect system

exec dbms_session.session_trace_enable
select 'hello, world' from dual;
exec dbms_session.session_trace_disable

@my-trace-file
@my-trace-contents

