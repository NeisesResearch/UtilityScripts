
# Michael Neises
# 27 February 2023
# Collect, compose, and otherwise prepare my dissertation project for
# development and testing

# 1. Create a directory named for today
dir=dissertation-`date +"%d%B%Y"`
mkdir ${dir} &&
cd ${dir} &&

# 2. clone am-cakeml
git clone git@github.com:KU-SLDG/am-cakeml -b attarch-measurement-integration &&

# 3. clone attarch
#git clone git@github.com:KU-SLDG/attarch -b measurement_integration &&
git clone git@github.com:KU-SLDG/attarch -b introspect_rebase &&

# 4. Place an update script in today's directory
echo "
# Step 1: Remove contents of test_build/attarch except the linux subdirectory
find test_bench/attarch/ -mindepth 1 -type d -not -wholename '*/linux/*' -not -name 'linux' -exec rm -rf {} +
rsync -av attarch/ test_bench/attarch/ &&
rsync -av am-cakeml/ test_bench/attarch/am-cakeml/
" > updateProject.sh &&

# 5. Create a test_bench directory
mkdir test_bench && cd test_bench &&

# 6. init and sync the repo
repo init -u https://github.com/ku-sldg/attarch-manifest.git -b measurement_integration && repo sync &&

# 7. clone the seL4 dockerfiles
git clone git@github.com:seL4/seL4-CAmkES-L4v-dockerfiles.git &&

# 8. edit the extras.Dockerfile to get the right version of cakeML
echo "
RUN curl -L https://github.com/CakeML/cakeml/releases/download/v2076/cake-x64-32.tar.gz > cake-x64-32.tar.gz \\
    && tar -xvzf cake-x64-32.tar.gz && cd cake-x64-32 && make cake \\
    && mv cake /usr/bin/cake32

RUN curl -L https://github.com/CakeML/cakeml/releases/download/v2076/cake-x64-64.tar.gz > cake-x64-64.tar.gz \\
    && tar -xvzf cake-x64-64.tar.gz && cd cake-x64-64 && make cake \\
    && mv cake /usr/bin/cake64" >> seL4-CAmkES-L4v-dockerfiles/dockerfiles/extras.Dockerfile &&


# 9. Place a startDocker script in today's directory
echo "
THIS_DIR=\`pwd\`
cd seL4-CAmkES-L4v-dockerfiles &&
make user HOST_DIR=\$THIS_DIR
" > startDocker.sh &&
chmod +x startDocker.sh &&

# 10. Build the linux kernel
cd attarch && ./buildLinux.sh &&

echo "done"

