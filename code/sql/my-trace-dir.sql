-- print my trace directory name

select value "TRACE DIRECTORY" from v$diag_info where name = 'Diag Trace';

