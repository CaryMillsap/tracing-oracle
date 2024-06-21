#!/bin/bash

# Fill a disk (for testing disk-consumption-rate.pl)

output_dir="DELETE-ME"
output_file="delete-me.img"
output_path="$output_dir/$output_file"
tmp_file="tmp.img"

cleanup() {
   # One could clean up here, but that throws off the disk-consumption-rate.pl totals.
   # Cleanup is thus left for the user to take care of.
   #
   # rm "$output_path"    # one component at a time, ...
   # rmdir "$output_dir"  # ...just to be safe
   printf "\n"
   printf "$output_path\n"
   ls -lh "./$output_dir" | tail -1
   exit 0
}
trap cleanup SIGINT

rm "$output_path"       # No need having the file start off big.
mkdir -p "$output_dir"

while true; do
   dd if=/dev/urandom of="$tmp_file" bs=1024 count=100 conv=notrunc oflag=fsync status=none    # speed=2m
   cat "$tmp_file" >> "$output_path"
   rm "$tmp_file"
   printf "."
   sleep 1
done


