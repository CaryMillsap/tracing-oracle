-- execute upon SQLcl startup

set sqlformat default
set heading off
select 'Hello '||user||' from your login.sql' from dual;

set sqlformat ansiconsole
