-- "hello, world", your first trace

/*

This script will NOT run on an Oracle Autonomous Database system.

If you cannot connect as SYSTEM, then you'll need a DBA to grant the following:

    grant execute on dbms_session to <username>
    grant alter session to <username>

*/

connect system

@trace-on
select 'hello, world' from dual;
@trace-off

@my-trace-file
@my-trace-content

