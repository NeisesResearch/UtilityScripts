#!/bin/bash
set -e
set -x

# call this file from test_bench
dir_name=$(pwd)
regex=".*/([0-9]+\.[0-9]+\.y).*"

if [[ $dir_name =~ $regex ]]
then
    version=${BASH_REMATCH[1]}
    echo $version
else
    echo "No match"
fi


cd build
(./simulate | tee /mnt/workspace/dissertation/continteg/SimulationResults/result-${version}) &
simulate_pid=$!
sleep 10
kill -INT $simulate_pid

pkill -f 'qemu-system-aarch64'

echo "Finished: ${version}"

