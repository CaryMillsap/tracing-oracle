-- enable tracing for my session

alter session set max_dump_file_size=unlimited;
alter session set statistics_level=typical;
select value file from v$diag_info where name='Default Trace File';
exec dbms_session.session_trace_enable;


