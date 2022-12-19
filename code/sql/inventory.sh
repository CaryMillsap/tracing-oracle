#!/bin/bash

# Create script inventory.

for FILENAME in *.sql
do
	echo "$FILENAME" $(head -1 $FILENAME | sed "s/--/-/g")
done | nl

