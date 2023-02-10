-- set appinfo off
set appinfo on

select sys_context('userenv','service_name')||'/'||sys_context('userenv','module')||'/'||sys_context('userenv','action') "service/module/action" from dual;
@test2
select sys_context('userenv','service_name')||'/'||sys_context('userenv','module')||'/'||sys_context('userenv','action') "service/module/action" from dual;

