#!/bin/bash

# Your .trc directory name goes here
TRCDIR=/DIR/diag/rdbms/DBNAME/INSTNAME/trace/	

N=14		# 7, 14, 28 are good numbers for most people

# #TODO - Use lsof or ps to ensure that we're not going to delete an open file.

find $TRCDIR -type f -name \*.tr[cm] -mtime +$N -delete

