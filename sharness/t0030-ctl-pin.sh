#!/bin/bash

test_description="Test cluster-ctl's pinning and unpinning functionality"


. lib/test-lib.sh

test_ipfs_init
cleanup test_clean_ipfs
test_cluster_init
cleanup test_clean_cluster


test_expect_success IPFS,CLUSTER "pin data to cluster with ctl" '
    cid=$(echo "test" | ipfs add -q) &&
    echo $cid &&
    ipfs-cluster-ctl pin add "$cid" &&
    ipfs-cluster-ctl pin ls "$cid" | grep -q "$cid" &&
    ipfs-cluster-ctl status "$cid" | grep -q -i "PINNED"
'

test_expect_success IPFS,CLUSTER "unpin data from cluster with ctl" '
    ipfs-cluster-ctl pin rm "$cid" &&
    !(ipfs-cluster-ctl pin ls "$cid" | grep -q "$cid") &&
    ipfs-cluster-ctl status "$cid" | grep -q -i "UNPINNED"
'

test_done
