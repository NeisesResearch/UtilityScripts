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

cp BuildThisDissertationWorkstation.sh ${apps_directory}
cd ${apps_directory}

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
    cd ${apps_directory}
    if [ ! -d "${version}-linux/test_bench" ]; then
        echo "Error: Directory '${version}-linux/test_bench' does not exist."
        continue
    fi

    cd "${version}-linux/test_bench"

    if [ ! -f "${utility_scripts_directory}/RunDocker.sh" ]; then
        echo "Error: File '${utility_scripts_directory}/RunDocker.sh' does not exist."
        continue
    fi

    cp ${utility_scripts_directory}/RunDocker.sh .

    if [ ! -f "${utility_scripts_directory}/RunQemu.sh" ]; then
        echo "Error: File '${utility_scripts_directory}/RunQemu.sh' does not exist."
        continue
    fi

    cp ${utility_scripts_directory}/RunQemu.sh .

    if ! ./RunDocker.sh | tee ${results_directory}/buildlog-${version}; then
        echo "Error: Failed to run 'RunDocker.sh'."
        continue
    fi

    if ! ./RunQemu.sh | tee ${results_directory}/result-${version}; then
        echo "Error: Failed to run 'RunQemu.sh'."
        continue
    fi

    echo "Finished: ${version}"
done

