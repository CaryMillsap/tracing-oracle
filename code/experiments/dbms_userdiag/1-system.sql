-- test 23c new DBMS_USERDIAG features


connect sys/oracle as sysdba
show user

drop user dev2 cascade;
create user dev2 identified by oracle;
grant create session to dev2;
grant execute on sys.dbms_userdiag to dev2;


