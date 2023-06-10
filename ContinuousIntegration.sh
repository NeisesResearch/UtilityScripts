#!/bin/bash
set -e
set -x

versions=(
"4.9.y"
"4.14.y"
"4.19.y" 
"5.4.y" 
 "5.10.y" 
"5.15.y" 
"6.1.y"
)

cp BuildThisDissertationWorkstation.sh ${apps_directory}
cd ${apps_directory}

export utility_scripts_directory
#for version in "${versions[@]}"; do
#    rm -rf "${version}-linux"
#    nohup ./BuildThisDissertationWorkstation.sh "$version" &
#done

wait
echo "All Dissertation Workstations Prepared"

# Ensure versions array is not empty
if [ ${#versions[@]} -eq 0 ]; then
    echo "Error: versions array is empty."
    exit 1
fi

for version in "${versions[@]}"; do
    echo $apps_directory
    echo ${version}
    test_bench="${apps_directory}/${version}-linux/test_bench"
    if [ ! -d "${test_bench}" ]; then
        echo "Error: Directory '${test_bench}' does not exist."
        continue
    fi
    #cd "${version}-linux/test_bench"
    cd ${test_bench}

    if [ ! -f "${utility_scripts_directory}/RunDocker.sh" ]; then
        echo "Error: File '${utility_scripts_directory}/RunDocker.sh' does not exist."
        continue
    fi

    cp ${utility_scripts_directory}/RunDocker.sh .

    if ! ./RunDocker.sh | tee ${results_directory}/buildlog-${version}; then
        echo "Error: Failed to run 'RunDocker.sh'."
        continue
    fi

    cd build
    (./simulate | tee ${results_directory}/result-${version}) &
    simulate_pid=$!
    sleep 10
    kill -INT $simulate_pid

    python3 ${utility_scripts_directory}/Provision.py ${results_directory}/result-${version} ${test_bench}/attarch/components/Measurement/
    cd ${test_bench}
    if ! ./RunDocker.sh | tee ${results_directory}/buildlog-${version}; then
        echo "Error: Failed to run 'RunDocker.sh'."
        continue
    fi

    cd build
    (./simulate | tee ${results_directory}/result-${version}) &
    simulate_pid=$!
    sleep 10
    kill -INT $simulate_pid

    echo "Finished: ${version}"
done

pkill -f 'qemu-system-aarch64'

# now compile and email me the results
# this script apparently didn't fire.
# After night 1, the apps build and simulated, and the results and buildlogs
# were collected.
# However, the final results were never compiled. It's not clear why.
source $utility_scripts_directory/ProcessIntegrationResults.sh

