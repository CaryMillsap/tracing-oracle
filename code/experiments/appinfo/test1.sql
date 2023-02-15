-- demonstrate what happens when you use appinfo

@trace-on

set appinfo on

-- Note that if we use @my-handles instead of the select statement below, then
-- the script name part of the MODULE name will always be my-handles.sql, which
-- is not what we want.

select sys_context('userenv','service_name')||'/'||sys_context('userenv','module')||'/'||sys_context('userenv','action') "service/module/action" from dual;
@test2
select sys_context('userenv','service_name')||'/'||sys_context('userenv','module')||'/'||sys_context('userenv','action') "service/module/action" from dual;

@trace-off
@my-trace-file


-- If you want to chase the boundaries of what Oracle does when the script name
-- is long, use the fully-qualified pathname in the @test2 call. On my system,
-- I got this:

-- script name: /u01/app/oracle/diag/rdbms/orclcdb/orclcdb/trace/test2.sql
-- module name: 01<le/diag/rdbms/orclcdb/orclcdb/trace/test2.sql

