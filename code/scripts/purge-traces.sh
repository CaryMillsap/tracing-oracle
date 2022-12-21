#!/bin/bash

TRCDIR=/DIR/diag/rdbms/DBNAME/INSTNAME/trace/	# Your .trc directory name goes here
N=14											# 7, 14, 28 are good numbers for most people

find $TRCDIR -type f -name \*.tr[cm] -mtime +$N -delete

