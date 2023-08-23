-- Insert a datestamp and trace file name into a trace file

-- NOTES ONLY (does not run) by Cary Millsap

-- Credit Jared Still for the idea.
-- See also:
--    http://www.juliandyke.com/Diagnostics/Tools/ORADEBUG/ORADEBUG.php

/* 

The interesting thing being demonstrated below is the use of `ORADEBUG
TRACEFILE_NAME` to drop a datestamp into the process's trace file, which will
look like this:

   *** 2023-05-20T05:08:14.557296+00:00
   Received ORADEBUG command (#4) 'tracefile_name' from process '2772'
   
   *** 2023-05-20T05:08:14.557330+00:00
   Finished processing ORADEBUG command (#4) 'tracefile_name'

Such a datestamp can be useful for marking the beginning and ending of a user's
online experience within the trace. Of course, if you can get a tightly scoped
trace file by enabling and disabling a trace at exactly the right times (such
as with DBMS_MONITOR.CLIENT_ID_TRACE_ENABLE or SERV_MOD_ACT_TRACE_ENABLE),
then you should do that.

Before you can use ORADEBUG TRACEFILE_NAME, you'll need to find the
V$PROCESS.PID value of the session you want to trace. You can enable tracing
for a given session with DBMS_MONITOR (that's what I recommend), or you can use
the ORADEBUG EVENT syntax.   

*/

oradebug setorapid PID

oradebug event 10046 trace name context forever, level 8
oradebug tracefile_name

-- User's work to be traced happens here.

oradebug tracefile_name
oradebug event 10046 trace name context off



