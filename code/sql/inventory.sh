#!/bin/bash

# Create script inventory.

# Assumptions:
# - All files have /.sql/ name suffix.
# - First line of each file matches /^-- program description/.
#
for FILENAME in *.sql
do
	echo "$FILENAME" $(head -1 $FILENAME | sed "s/^--/-/g")
done | nl

