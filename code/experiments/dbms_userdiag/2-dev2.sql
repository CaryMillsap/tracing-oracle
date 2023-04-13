-- test 23c new DBMS_USERDIAG features


connect dev2/oracle
show user

set autoprint on
var level number

-- Can DEV2 set tracefile identifier without ALTER SESSION (like DBMS_SESSION requires)?
@my-trace-file
exec dbms_userdiag.set_tracefile_identifier('cary')
@my-trace-file

-- Can DEV2 start tracing?
@my-trace-status
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1)
exec dbms_userdiag.check_sql_trace_event(:level)
@my-trace-status

exec dbms_userdiag.enable_sql_trace_event(disable=>1)
exec dbms_userdiag.check_sql_trace_event(:level)

-- What happens when LEVEL conflicts with, say, BINDS?
exec dbms_userdiag.enable_sql_trace_event(level=>12,binds=>0)
exec dbms_userdiag.check_sql_trace_event(:level)

exec dbms_userdiag.enable_sql_trace_event(level=> 8,binds=>1)
exec dbms_userdiag.check_sql_trace_event(:level)

-- Moral: use (LEVEL) or (WAITS,BINDS,PLAN_STAT), but don't mix.

-- Does SYS=>1 create a database-wide trace?

-- Does SES=>:session,SER=>:serial work?

-- Does PLAN_STAT=>ADAPTIVE work? Yes!
select 'dbms_userdiag';
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1,plan_stat=>'never')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1,plan_stat=>'first_execution')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1,plan_stat=>'all_executions')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1,plan_stat=>'adaptive')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_userdiag.enable_sql_trace_event(waits=>1,binds=>1,plan_stat=>'nonsense')
exec dbms_userdiag.check_sql_trace_event(:level)

select 'dbms_monitor';
exec dbms_monitor.session_trace_enable(waits=>true,binds=>true,plan_stat=>'never')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_monitor.session_trace_enable(waits=>true,binds=>true,plan_stat=>'first_execution')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_monitor.session_trace_enable(waits=>true,binds=>true,plan_stat=>'all_executions')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_monitor.session_trace_enable(waits=>true,binds=>true,plan_stat=>'adaptive')
exec dbms_userdiag.check_sql_trace_event(:level)
exec dbms_monitor.session_trace_enable(waits=>true,binds=>true,plan_stat=>'nonsense')
exec dbms_userdiag.check_sql_trace_event(:level)

