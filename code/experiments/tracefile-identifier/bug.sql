-- TRACEFILE_IDENTIFIER behavior SR 3-32741539641

/*

Setting TRACEFILE_IDENTIFIER leaves information out of the trace file

When you set TRACEFILE_IDENTIFIER, the Oracle kernel process closes the
existing trace file and opens a new one. The new file doesn't contain all of
the information that it should. Specifically, it will not contain some
"PARSING IN CURSOR" sections that have been written to the first of the two
trace files. Impact is that, when we look at the trace file whose name has
the new tracefile identifier in it, we can't determine the SQL or PL/SQL
associated with all the cursors reported on in the trace. The workaround is
to simply never use TRACEFILE_IDENTIFIER. This has been a problem since at
least Oracle 10g, and it's still reproducible in 23c FREE. 

*/



-- Connect.
connect system/oracle

-- Enable trace.
exec dbms_monitor.session_trace_enable

-- Display the trace file name.
select value trace1 from v$diag_info where name = 'Default Trace File';

-- Execute some SQL.
select 1;

-- Close the old trace file and open a new one.
alter session set tracefile_identifier='new-file';

-- Display the new trace file name.
select value trace2 from v$diag_info where name = 'Default Trace File';

-- Execute the same SQL for the new trace file.
select 1;

-- Disable trace.
exec dbms_monitor.session_trace_disable

/*

Now, look in the two trace files.

In TRACE1, you'll see a 'PARSING IN CURSOR' section for the 'select 1' cursor.

In TRACE2, there is no 'PARSING IN CURSOR' section for the cursor.

It appears that the DBMS is checking a state variable holding the information,
"Have I emitted a 'PARSING IN CURSOR' section for this cursor?" The real
information needs to be "Have I emitted a 'PARSING IN CURSOR' section for this
cursor SINCE OPENING THE CURRENT TRACE FILE?"

The impact of this behavior is:

1. People like the TRACEFILE_IDENTIFIER feature because it makes it easier to
find their trace file in the trace directory. But the trace file created after
a TRACEFILE_IDENTIFIER change is deficient in that it does not contain the SQL
or PL/SQL associated with all the dbcalls in the trace.

3. The easiest workaround is to simply never use TRACEFILE_IDENTIFIER. That is
my recommendation to people. It seems like a nice-to-have feature, but it's so
easy these days to find the name of your trace file in V$DIAG_INFO that we
recommend using that instead of TRACEFILE_IDENTIFIER.

4. A harder workaround (NOBODY will want to do this [or even know how]) is to
always save both the "before" (TRACE1 in this example) and "after" (TRACE2 in
this example) files, and then do sophisticated trace file surgery in an
editor (being extremely careful with the tim values!), to provide the "PARSING
IN CURSOR" information to any user of the "after" trace file.

*/

