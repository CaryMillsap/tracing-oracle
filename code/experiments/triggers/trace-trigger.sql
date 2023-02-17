-- create a trigger to enable tracing

create or replace trigger mr_trace_aftlogon_all
after logon on schema
begin
   sys.dbms_session.session_trace_enable;
   exception when others then null;
end;
/
