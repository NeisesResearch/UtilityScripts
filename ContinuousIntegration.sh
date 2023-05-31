#!/bin/bash

cd /mnt/continteg

# Directory where the git repository should be
repo_directory="UtilityScripts"

# Check if the directory exists
if [ -d "$repo_directory" ]; then
    echo "$repo_directory exists. Pulling latest changes."
    cd $repo_directory
    git pull
    cd ..
else
    echo "$repo_directory does not exist. Cloning the repository."
    git clone git@github.com:NeisesResearch/UtilityScripts.git
fi

versions=("4.9.y"
# "4.19.y" 
#"5.4.y" 
# "5.10.y" 
#"5.15.y" 
#"6.1.y"
)

cp UtilityScripts/BuildThisDissertationWorkstation.sh ./dev/
cd dev

for version in "${versions[@]}"; do
    rm -rf "${version}-linux"
    nohup ./BuildThisDissertationWorkstation.sh "$version" &
done

wait
echo "All Dissertation Workstations Built"

for version in "${versions[@]}"; do
    cd "${version}-linux/test_bench"
    cp /mnt/continteg/UtilityScripts/RunDocker.sh .
    cp /mnt/continteg/UtilityScripts/RunQemu.sh .
    RunDocker.sh
    RunQemu.sh
    cd ../../
done





