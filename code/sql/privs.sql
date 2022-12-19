-- grant tracing privileges

-- Copyright (c) 2022 Method R Corporation

create role mrdba;
create role mrappdev;
create role mruser;

grant execute on dbms_application_info to mrdba, mrappdev;

grant execute on dbms_session to mrdba, mrappdev;
grant execute on dbms_monitor to mrdba;

grant execute on dbms_log to mrdba, mrappdev;



connect system
grant connect to mr identified by mr;
grant create procedure to mr;
grant alter session to mr;
grant execute on dbms_session to mr;

connect mr
grant execute on dev_trace to cary;

