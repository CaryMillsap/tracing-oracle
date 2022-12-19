-- disable tracing for all USERNAME=&1 sessions

-- Copyright (c) 2019, 2022 Method R Corporation

-- Stop tracing new sessions.
alter trigger &1.trg_no_sys_logon disable;

-- Disable tracing for all existing USERNAME sessions.
begin
	for r in (select sid, serial# from v$session where type='USER' and username = '&1') loop
		dbms_monitor.session_trace_disable(r.sid, r.serial#);
	end loop;
end;


