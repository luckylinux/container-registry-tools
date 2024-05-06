#!/bin/bash

# File must be in /etc/supercronic/XXX
mapfile -t files < <( find /etc/supercronic -type f )

for file in "${files[@]}"
do
   # Run Supercronic & Redirect Output of Children processes to Docker Log:
   # https://stackoverflow.com/questions/55444469/redirecting-script-output-to-docker-logs
   supercronic -split-logs ${file} 1> /proc/1/fd/1 2> /proc/1/fd/2 &
done

# Infinite Loop
while [ true ]
do
    # Sleep for 1 second
    sleep 1
done
