#!/bin/bash
set -e
set -x

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

# Ensure versions array is not empty
if [ ${#versions[@]} -eq 0 ]; then
    echo "Error: versions array is empty."
    exit 1
fi

for version in "${versions[@]}"; do
    cd ${apps_directory}
    if [ ! -d "${version}-linux/test_bench" ]; then
        echo "Error: Directory '${version}-linux/test_bench' does not exist."
        continue
    fi

    cd "${version}-linux/test_bench"

    # git pull
    cd ../attarch
    git pull
    cd ..
    ./updateSource.sh
    cd test_bench

    # build app
    if [ ! -f "${utility_scripts_directory}/RunDocker.sh" ]; then
        echo "Error: File '${utility_scripts_directory}/RunDocker.sh' does not exist."
        continue
    fi
    cp ${utility_scripts_directory}/RunDocker.sh .
    if ! ./RunDocker.sh | tee ${results_directory}/buildlog-${version}; then
        echo "Error: Failed to run 'RunDocker.sh'."
        continue
    fi

    # simulate it
    cd build
    (./simulate | tee ${results_directory}/result-${version}) &
    simulate_pid=$!
    sleep 10
    kill -INT $simulate_pid

    echo "Finished: ${version}"
done

