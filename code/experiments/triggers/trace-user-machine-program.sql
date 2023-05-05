-- Copyright (c) 2019, 2022 Method R Corporation

-- Usage trace-machine-program enable|disable <trigger owner> <user name> <program name> <machine name>

set serveroutput on

define usr_name=&3
define pgm_name=&4
define mach_name=&5

create or replace trigger &2.trg_trace_directive
   after logon on schema
begin
   for s in (select * from SYS.V_$SESSION where SID = sys_context('userenv', 'SID')) loop
      if '&usr_name' = s.USERNAME and '&pgm_name' = s.PROGRAM and '&mach_name' = s.MACHINE then
         dbms_monitor.session_trace_enable(null, null, true, false, 'first_execution');
      end if;
   end loop;
   exception when others then null;
end;
/
show errors

alter trigger &2.trg_trace_directive &1;


declare
   n number := 0;
begin
   for s in (select * from SYS.V_$SESSION where '&usr_name' = USERNAME and '&pgm_name' = PROGRAM and '&mach_name' = MACHINE) loop
      if '&1' = 'enable' then
         dbms_monitor.session_trace_enable(s.sid, s.serial#, true, false, 'first_execution');
         n := n + 1;
      else
         dbms_monitor.session_trace_disable(s.sid, s.serial#);
         n := n + 1;
      end if;
   end loop;
   if '&1' = 'enable' then
      dbms_output.put_line('enabled trace for ' || n || ' sessions');
   else
      dbms_output.put_line('disabled trace for ' || n || ' sessions');
   end if;
end;
/

