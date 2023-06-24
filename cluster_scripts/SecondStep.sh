#!/bin/bash
#SBATCH --job-name=BuildKernel
#SBATCH --output=BuildKernel-%j.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32  # adjust this to your needs
#SBATCH --nodes=1
#SBATCH --time=72:00:00
#SBATCH --partition=intel
#SBATCH --exclusive 

# Michael Neises
# 27 February 2023
# Collect, compose, and otherwise prepare my dissertation project for
# development and testing
# Modifications and improvements provided by OpenAI's ChatGPT-4

# Accept input as a command line argument
project_dir=$1

# Check if the argument was given
if [ -z "$project_dir" ]; then
    echo "No project dir specified. Please specify /mnt/continteg or /nfs/users/m811n155"
    exit 1
fi
# Check if the argument is a valid project_dir
if [ ! -d "$project_dir" ]; then
  echo "Directory '$project_dir' does not exist."
  exit 1
fi

# Accept input as a command line argument
opt=$2

# Check if the argument was given
if [ -z "$opt" ]; then
    echo "No Linux kernel version provided. Note that 4.9.y is no longer supported."
    exit 1
fi

# Array of options
options=("4.9.y" "4.14.y" "4.19.y" "5.4.y" "5.10.y" "5.15.y" "6.1.y")

# Check if the argument is a valid option
valid=false
for i in "${options[@]}"; do
    if [ "$i" == "$opt" ]; then
        valid=true
        break
    fi
done

if $valid; then
    echo "You chose version $opt"
else
    echo "Invalid option $opt"
    exit 1
fi


# 1. Create a directory named for the version of linux
dir="$project_dir/$opt-linux"
cd "${dir}/test_bench/attarch/linux-stable" || { echo "Failed to change directory to: ${dir}/test_bench/attarch/linux-stable"; exit 1; }

# ensure the working directories are clean
# Clean the build using make clean and remove config files if they exist
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- clean || { echo "Failed to clean"; exit 1; }
rm -f .config .config.old Module.symvers || { echo "Failed to remove .config, .config.old, or Module.symvers"; exit 1; }

# copy in our specific config file
# Copy the specific config file and check if operation was successful
cp  ../../../../../camkes-vm-images/qemu-arm-virt/linux_configs/config .config || { echo "Failed to copy config file"; exit 1; }
cp .config .config.old || { echo "Failed to backup .config file"; exit 1; }

# when our config file doesn't account for some of this kernel version's
# options, choose the default everywhere.
# Update the config file with default options for new options
yes "" | make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- oldconfig || { echo "Failed to update .config file"; exit 1; }

# prepare the source tree for compilation
# Prepare the source tree for compilation and check if operation was successful
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- prepare || { echo "Failed to prepare source tree for compilation"; exit 1; }

# compile the kernel using all available CPU cores
# Compile the kernel and check if operation was successful
make -j${SLURM_CPUS_PER_TASK} ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- || { echo "Failed to compile the kernel"; exit 1; }





