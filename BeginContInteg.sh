#!/bin/bash
set -e
#set -x

# This is where all the linux kernels will be stored together with their app.
# This directory should be able to support ~80 gigabytes of data
project_directory=$1

if [ -z "$project_directory" ]; then
    echo "No project directory provided. Please specify /mnt/continteg or perhaps /scratch/m811n155"
    exit 1
fi

# Directory where the git repository should be
utility_scripts_directory="${project_directory}/UtilityScripts/"

# Directory where the simulation results should go
results_directory="${project_directory}/SimulationResults/"

# Directory where the apps should go
apps_directory="${project_directory}/dev/"

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


