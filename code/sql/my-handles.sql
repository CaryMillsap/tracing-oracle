-- print my user session handle attribute values

select       sys_context('userenv', 'service_name')
   || '/' || sys_context('userenv', 'module')
   || '/' || sys_context('userenv', 'action')
   || '/' || sys_context('userenv', 'client_identifier')
   "SERVICE/MODULE/ACTION/CLIENTID"
from
   dual
/

