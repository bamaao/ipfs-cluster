# Sharness test framework for ipfs-cluster
#
# We are using sharness (https://github.com/mlafeldt/sharness)
# which was extracted from the Git test framework.

SHARNESS_LIB="lib/sharness/sharness.sh"

# Daemons output will be redirected to...
IPFS_OUTPUT="/dev/null" # change for debugging
#IPFS_OUTPUT="/dev/stderr" # change for debugging

. "$SHARNESS_LIB" || {
    echo >&2 "Cannot source: $SHARNESS_LIB"
    echo >&2 "Please check Sharness installation."
    exit 1
}

which jq &>/dev/null
if [ $? -eq 0 ]; then
    test_set_prereq JQ
fi

# Set prereqs
test_ipfs_init() {
    which ipfs &>/dev/null
    if [ $? -ne 0 ]; then
        echo "IPFS not found"
        exit 1
    fi
    export IPFS_TEMP_DIR=`mktemp -d ipfs-XXXXX` # Store in TEMP_DIR for safer delete
    export IPFS_PATH=$IPFS_TEMP_DIR
    ipfs init &>$IPFS_OUTPUT
    if [ $? -ne 0 ]; then
        echo "Error initializing ipfs"
        exit 1
    fi
    ipfs daemon &>$IPFS_OUTPUT &
    export IPFS_D_PID=$!
    sleep 5
    test_set_prereq IPFS
}

test_cluster_init() {
    which ipfs-cluster-service &>/dev/null
    if [ $? -ne 0 ]; then
        echo "ipfs-cluster-service not found"
        exit 1
    fi
    which ipfs-cluster-ctl &>/dev/null
    if [ $? -ne 0 ]; then
        echo "ipfs-cluster-ctl not found"
        exit 1
    fi
    CLUSTER_TEMP_DIR=`mktemp -d cluster-XXXXX`
    ipfs-cluster-service -f --config $CLUSTER_TEMP_DIR init &>$IPFS_OUTPUT
    ipfs-cluster-service --config $CLUSTER_TEMP_DIR &>$IPFS_OUTPUT &
    export CLUSTER_D_PID=$!
    sleep 5
    test_set_prereq CLUSTER
}

test_cluster_config() {
    export CLUSTER_CONFIG_PATH=$CLUSTER_TEMP_DIR"/service.json"
    export CLUSTER_CONFIG_ID=`jq --raw-output ".id" $CLUSTER_CONFIG_PATH`
    export CLUSTER_CONFIG_PK=`jq --raw-output ".private_key" $CLUSTER_CONFIG_PATH`
    [ $CLUSTER_CONFIG_ID != null ] && [ $CLUSTER_CONFIG_PK != null ]
}

# Cleanup functions
test_clean_ipfs(){
    kill -1 $IPFS_D_PID &&
    rm -rf $IPFS_TEMP_DIR    # Remove temp_dir not path in case this is called before init
}

test_clean_cluster(){
    kill -1 $CLUSTER_D_PID &&
    rm -rf $CLUSTER_TEMP_DIR
}
