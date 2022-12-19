-- print info about standing traces

-- Note that this query will report only upon traces enabled with:
-- - dbms_monitor.client_id_trace_enable
-- - dbms_monitor.serv_mod_act_trace_enable
-- - dbms_monitor.database_trace_enable

select
	instance_name,
	trace_type,
	primary_id,
	qualifier_id1,
	qualifier_id2,
	waits,
	binds,
	plan_stats
from
	dba_enabled_traces
/


-- Note that this will report only upon traces enabled with oradebug.

-- oradebug setmypid
-- oradebug eventdump system
