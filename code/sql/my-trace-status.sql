-- print info about my active traces

select
     sid                   sid
   , serial#               serial
   , service_name          service
   , module                module
   , action                action
   , client_identifier     clientid
   , sql_trace             trace
   , sql_trace_waits       waits
   , sql_trace_binds       binds
   , sql_trace_plan_stats  planstats
from
   v$session
where
   sid = sys_context('userenv','sid')
/

