#!/bin/bash

# Create script inventory.

# Assumptions:
# - All files have /.sql/ name suffix.
# - First line of each file matches /^-- program description/.
# - All files match *.sql or */*.sql

for FILENAME in *.sql */*.sql
do
   echo "$FILENAME" $(head -1 $FILENAME | sed "s/^--/-/g")
done | nl

