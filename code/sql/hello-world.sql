-- "hello, world", your first trace

-- This script will NOT run on an Oracle Autonomous Database system.

-- See (dba|dev)-trace-permissions.sql for information about required
-- privileges if the following scripts fail for you.

-- connect system

@trace-on
select 'hello, world' from dual;
@trace-off
@my-trace-dir
@my-trace-file
@my-trace-content

