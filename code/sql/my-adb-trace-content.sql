-- print trace contents for ADB

/* 

Requires `grant read on session_cloud_trace to <username>`

*/

select trace from session_cloud_trace order by row_number
/
