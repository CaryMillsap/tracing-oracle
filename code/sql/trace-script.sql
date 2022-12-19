-- trace &1.sql

/*
  Execute this from any tool capable of executing sqlplus scripts. Do it
  like this:

  SQL> @trace-script scriptYouWantToTrace.sql

  It will attempt to terminate the current tool's session normally so
  the RDBMS has an opportunity to record critical end-of-trace information.

*/

spool trace-script.out

start trace-on

start &&1

spool off

exit

