#!/bin/bash
set -e
set -x

# This is where all the linux kernels will be stored together with their app.
# This directory should be able to support ~60 gigabytes of data
project_directory="/mnt/continteg"

# Directory where the git repository should be
utility_scripts_directory="UtilityScripts"

# Directory where the simulation results should go
results_directory="SimulationResults"

export project_directory
export utility_scripts_directory
export results_directory

cd ${project_directory}

# Check if the results directory exists
if [ -d "$results_directory" ]; then
    echo "$results_directory exists. Wiping it."
    rm -rf $results_directory
else
    echo "$results_directory does not exist. Making it."
fi
mkdir  $results_directory

# Check if the repo directory exists
if [ -d "$utility_scripts_directory" ]; then
    echo "$utility_scripts_directory exists. Pulling latest changes."
    cd $utility_scripts_directory
    git pull
    cd ..
else
    echo "$utility_scripts_directory does not exist. Cloning the repository."
    git clone git@github.com:NeisesResearch/UtilityScripts.git
fi

cd $utility_scripts_directory


# Now we're in the /mnt/continteg/UtilityScripts dir
source ./ContinuousIntegration.sh


