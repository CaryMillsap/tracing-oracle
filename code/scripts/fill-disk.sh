#!/bin/bash

# Fill a disk (for testing disk-consumption-rate.pl)

output_dir="dcrtest"
output_file="fill_disk.img"
output_path="$output_dir/$output_file"
tmp_file="delete-me.img"

mkdir -p "$output_dir"

while true; do
   dd if=/dev/urandom of="$tmp_file" bs=1024 count=100 conv=notrunc status=progress
   cat "$tmp_file" >> "$output_path"
   rm "$tmp_file"
   sleep 1
done

rm -rf "$output_dir"

