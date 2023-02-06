-- "hello, world", your first trace

/*

This script will NOT run on an Oracle Autonomous Database system.

See (dba|dev)-trace-permissions.sql for information about required privileges
if you can't connect as SYSTEM.

*/

-- connect system

@trace-on
select 'hello, world' from dual;
@trace-off

@my-trace-file
@my-trace-content

