-- enable tracing for all USERNAME=&1 sessions

-- #TODO needs testing

-- Copyright (c) 2019, 2022 Method R Corporation

-- Enable tracing for any new USERNAME session.
create or replace trigger &1.trg_no_sys_logon
   after logon on schema
begin
   dbms_session.session_trace_enable;
   exception when others then null;
end;
/

-- Enable tracing for all existing USERNAME sessions.
begin
   for r in (select sid, serial# from v$session where type='USER' and username = '&1') loop
      dbms_monitor.session_trace_enable(r.sid, r.serial#);
   end loop;
end;
/

