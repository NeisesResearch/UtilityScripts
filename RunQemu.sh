#!/usr/bin/env bash
set -e
set -x

# Trap the INT signal
trap 'kill -INT $simulate_pid' INT

# Start the simulate script as a background job
cd build
./simulate &

# Get the PID of the simulate process
simulate_pid=$!

# Wait for 15 seconds
sleep 15

# Send an interrupt signal to the simulate process
kill -INT $simulate_pid

# Wait for the simulation task to terminate
wait $simulate_pid

# return to the starting directory
cd ..
