-- test 23c new DBMS_USERDIAG features


connect sys/oracle as sysdba
show user

drop user mr cascade;
create user mr identified by mr;
grant create session to mr;
grant execute on sys.dbms_userdiag to mr;

connect mr/mr
show user

-- Expect this to require ALTER SESSION
exec sys.dbms_userdiag.set_tracefile_identifier('cary')

-- Expect this to require ALTER SESSION
exec sys.dbms_userdiag.enable_sql_trace_event(waits=>1)

