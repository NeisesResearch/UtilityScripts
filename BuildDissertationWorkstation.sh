#!/bin/bash

# Michael Neises
# 27 February 2023
# Collect, compose, and otherwise prepare my dissertation project for
# development and testing
# Modifications and improvements provided by OpenAI's ChatGPT-4

# Display a menu and prompt for input
PS3="Please enter your choice of Linux kernel version. Note that 4.9.y is no longer supported. "
options=("4.9.y" "4.14.y" "4.19.y" "5.4.y" "5.10.y" "5.15.y" "6.1.y")
select opt in "${options[@]}"
do
    case $opt in
        "4.9.y"|"4.14.y"|"4.19.y"|"5.4.y"|"5.10.y"|"5.15.y"|"6.1.y")
            echo "You chose version $opt"
            break
            ;;
        *)
            echo "Invalid option $REPLY"
            ;;
    esac
done

# 1. Create a directory named for today
dir="dissertation-$(date +"%d%B%Y")"

# Create directory and check if operation was successful
mkdir "${dir}" || { echo "Failed to create directory: ${dir}"; exit 1; }

# Navigate into the created directory
cd "${dir}" || { echo "Failed to change directory to: ${dir}"; exit 1; }

# 2. clone am-cakeml
# Clone and check if operation was successful
git clone git@github.com:KU-SLDG/am-cakeml -b attarch-measurement-integration || { echo "Failed to clone am-cakeml repository"; exit 1; }

# 3. clone attarch
# Clone and check if operation was successful
git clone git@github.com:KU-SLDG/attarch -b introspect_rebase || { echo "Failed to clone attarch repository"; exit 1; }

# 4. Place an update script in today's directory
# Creates a script to update the project
cat <<EOF > updateProject.sh
# Step 1: Remove contents of test_build/attarch except the linux subdirectory
find test_bench/attarch/ -mindepth 1 -type d -not -wholename '*/linux-stable/*' -not -name 'linux-stable' -exec rm -rf {} +
rsync -av attarch/ test_bench/attarch/ &&
rsync -av am-cakeml/ test_bench/attarch/am-cakeml/
EOF

# 5. Create a test_bench directory and check if operation was successful
mkdir test_bench || { echo "Failed to create test_bench directory"; exit 1; }
cd test_bench || { echo "Failed to change directory to: test_bench"; exit 1; }

# 6. init and sync the repo
# Initialize and sync the repo, check if operation was successful
repo init -u https://github.com/ku-sldg/attarch-manifest.git -b introspect_rebase && repo sync || { echo "Failed to initialize and sync repo"; exit 1; }

# 7. clone the seL4 dockerfiles
# Clone and check if operation was successful
git clone git@github.com:seL4/seL4-CAmkES-L4v-dockerfiles.git || { echo "Failed to clone seL4 Dockerfiles"; exit 1; }

# 8. edit the extras.Dockerfile to get the right version of cakeML
# Append Dockerfile with commands to fetch the right version of CakeML
cat <<EOF >> seL4-CAmkES-L4v-dockerfiles/dockerfiles/extras.Dockerfile
RUN curl -L https://github.com/CakeML/cakeml/releases/download/v2076/cake-x64-32.tar.gz > cake-x64-32.tar.gz \\
    && tar -xvzf cake-x64-32.tar.gz && cd cake-x64-32 && make cake \\
    && mv cake /usr/bin/cake32

RUN curl -L https://github.com/CakeML/cakeml/releases/download/v2076/cake-x64-64.tar.gz > cake-x64-64.tar.gz \\
    && tar -xvzf cake-x64-64.tar.gz && cd cake-x64-64 && make cake \
&& mv cake /usr/bin/cake64
EOF

# 9. Place a startDocker script in today's directory
# Creates a script to start Docker
cat <<'EOF' > startDocker.sh
THIS_DIR=`pwd`
cd seL4-CAmkES-L4v-dockerfiles &&
make user HOST_DIR=$THIS_DIR
EOF
chmod +x startDocker.sh || { echo "Failed to make startDocker.sh executable"; exit 1; }

#!/bin/bash

# 10. Build the linux kernel
# Navigate into attarch directory and build the Linux kernel
cd attarch || { echo "Failed to change directory to: attarch"; exit 1; }

# Clone the Linux kernel with the chosen version
git clone --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable --branch linux-${opt} || { echo "Failed to clone Linux kernel"; exit 1; }

./buildLinux.sh || { echo "Failed to build the Linux kernel"; exit 1; }


python3 ScrapeSystemMap.py >> components/Measurement/configurations/linux_definitions.h || { echo "Failed to run ScrapeSystemMap.py"; exit 1; }


echo "done"

# from GPT:
# In this version, I added error checks after directory and repository operations, quoted all variables, and used heredocs (`<<EOF`) to make the inline script and Dockerfile additions more readable. I also made clear where each error check and modification was made.










