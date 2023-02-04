-- print trace contents for ADB

/* 

#TODO: How to grant SELECT on SESSION_CLOUD_TRACE to any user other than ADMIN?

2023-02-03 Oracle SR 3-32060937271 : Can't select from SESSION_CLOUD_TRACE (Cary Millsap)

*/

select trace from session_cloud_trace order by row_number
/
