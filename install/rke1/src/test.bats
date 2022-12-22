#!/bin/bash

setup() {
    load "../test/test_helper/bats-support/load"
    load "../test/test_helper/bats-assert/load"
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"
}

@test "run script's usage" {
    run rke-setup.sh -h
}

@test "run script with invalid argument" {
    run rke-setup.sh -a
}

@test "run script" {
    run rke-setup.sh
}

@test "verify RKE CLI is installed" {
    rke
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify kubectl CLI is installed" {
    kubectl
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify cluster.yml exists" {
    [ -f "cluster.yml" ]
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify kubectl get nodes works" {
    kubectl get nodes
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}