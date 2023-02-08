-- demonstrate the permissions a developer needs for tracing (ADB)

-- You must be ADMIN to perform the required trants.

-- connect admin

drop user dev1 cascade;						-- Fresh start
grant connect to dev1 identified by "Y0ur-Password-G0es-Here";
grant create session to dev1;

grant read on session_cloud_trace to dev1;	-- Required to read trace file content
grant alter session to dev1;				-- Required to enable and disable tracing

-- Connect for testing...
connect dev1/Y0ur-Password-G0es-Here

-- Ensure that the required views are accessible
desc session_cloud_trace

-- Full cycle: trace an application and access its content.
@adb/trace-on
select 'hello, from ADB' from dual;
@adb/trace-off
@adb/my-trace-content

