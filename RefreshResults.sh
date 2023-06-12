#!/bin/bash
set -e
#set -x

# Michael Neises
# 12 June 2023
# Git pull for every project, then provision, simulate, and process results
# Like a fresh build, but only for our own work

# This is where all the linux kernels will be stored together with their app.
# This directory should be able to support ~60 gigabytes of data
project_directory="/mnt/continteg"

# Directory where the git repository should be
utility_scripts_directory="${project_directory}/UtilityScripts"

# Directory where the simulation results should go
results_directory="${project_directory}/SimulationResults"

# Directory where the apps should go
apps_directory="${project_directory}/dev"


versions=(
"4.9.y"
"4.14.y"
"4.19.y" 
"5.4.y" 
 "5.10.y" 
"5.15.y" 
"6.1.y"
)

for version in "${versions[@]}"; do
    (
        test_bench="${apps_directory}/${version}-linux/test_bench"
        cd ${apps_directory}
        if [ ! -d "${test_bench}" ]; then
            echo "Error: Directory '${test_bench}' does not exist."
            continue
        fi

        cd "${test_bench}"

        # git pull
        cd ../attarch
        git pull > /dev/null 2>&1
        cd ..
        ./updateSource.sh > /dev/null 2>&1
        cd test_bench

        # build app
        if [ ! -f "${utility_scripts_directory}/RunDocker.sh" ]; then
            echo "Error: File '${utility_scripts_directory}/RunDocker.sh' does not exist."
            continue
        fi
        cp ${utility_scripts_directory}/RunDocker.sh .
        echo "Building ${version}"
        if ! ./RunDocker.sh > ${results_directory}/buildlog-${version} 2> /dev/null; then
            echo "Error: Failed to run 'RunDocker.sh'."
            continue
        fi

        cd build
        echo "Simulating ${version}"
        (./simulate > ${results_directory}/result-${version}) &
        simulate_pid=$!
        sleep 10
        kill -INT $simulate_pid
        echo "Finished Simulating ${version}"
    ) &
done

wait

for version in "${versions[@]}"; do
    test_bench="${apps_directory}/${version}-linux/test_bench"
    python3 ${utility_scripts_directory}/Provision.py ${results_directory}/result-${version} ${test_bench}/attarch/components/Measurement/
done

echo "Finished Baselining"

for version in "${versions[@]}"; do
    (
        test_bench="${apps_directory}/${version}-linux/test_bench"

        cd ${test_bench}

        # build app
        echo "Building ${version}"
        if ! ./RunDocker.sh > ${results_directory}/buildlog-${version}; then
            echo "Error: Failed to run 'RunDocker.sh'."
            continue
        fi

        cd build
        echo "Simulating ${version}"
        (./simulate > ${results_directory}/result-${version}) &
        simulate_pid=$!
        sleep 10
        kill -INT $simulate_pid

        echo "Finished Simulating ${version}"
    ) &
done

pkill -f 'qemu-system-aarch64'

source $utility_scripts_directory/ProcessIntegrationResults.sh

