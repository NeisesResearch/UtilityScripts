#!/bin/bash
set -e
set -x

versions=(
"4.9.y"
"4.19.y" 
"5.4.y" 
 "5.10.y" 
"5.15.y" 
"6.1.y"
)

apps_directory=/mnt/continteg/dev/
results_directory=/mnt/continteg/SimulationResults/
utility_scripts_directory=/mnt/continteg/UtilityScripts/
cd ${apps_directory}

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

# now compile and email me the results
# this script apparently didn't fire.
# After night 1, the apps build and simulated, and the results and buildlogs
# were collected.
# However, the final results were never compiled. It's not clear why.
source $utility_scripts_directory/ProcessIntegrationResults.sh

