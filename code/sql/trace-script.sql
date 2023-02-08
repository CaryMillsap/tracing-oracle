-- trace SCRIPT=&1

-- Execute this from any tool capable of executing sqlplus scripts.
-- Use it like this:
-- 
--   SQL> @trace-script YOUR-SCRIPT.sql
-- 
-- It will attempt to terminate the tool's session normally so the RDBMS can
-- write critical end-of-trace information.

@trace-on
@&1
exit

