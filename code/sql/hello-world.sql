-- "hello, world", your first trace

/*
  If you can connect as system, then you won't need any additional grants to
  run this script. Otherwise, if you connect as USERNAME, you'll need a DBA to
  grant the following:

    grant execute on dbms_session to USERNAME
    grant alter session to USERNAME

*/

connect system

select value file from v$diag_info where name='Default Trace File';
exec dbms_session.session_trace_enable
select 'hello, world' from dual;
exec dbms_session.session_trace_disable

