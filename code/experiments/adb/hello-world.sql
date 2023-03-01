-- "hello, world", your first trace (ADB-S)

-- This script will ONLY run on an Oracle Autonomous Database on shared
-- infrastructure system.

-- See adb/dev-trace-permissions.sql for information about required privileges
-- if you can't connect as ADMIN.

-- connect admin

@adb/trace-on
select 'hello, world' from dual;
@adb/trace-off
@adb/my-trace-content

