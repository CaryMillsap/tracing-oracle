-- print my trace file name

select value "TRACE FILE" from v$diag_info where name = 'Default Trace File';
