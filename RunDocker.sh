THIS_DIR=`pwd`
cd seL4-CAmkES-L4v-dockerfiles &&
make EXEC='bash -c "\
    rm -rf /host/build || { echo '\''Failed to delete /host/build'\''; exit 1; }; \
    mkdir /host/build || { echo '\''Failed to create /host/build'\''; exit 1; }; \
    cd /host/build || { echo '\''Failed to change to /host/build directory'\''; exit 1; }; \
    ../init-build.sh -DCAMKES_VM_APP=attarch -DPLATFORM=qemu-arm-virt && \
    ninja"' user HOST_DIR=$THIS_DIR

