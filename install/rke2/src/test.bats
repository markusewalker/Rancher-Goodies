#!/bin/bash

setup() {
    load "../test/test_helper/bats-support/load"
    load "../test/test_helper/bats-assert/load"
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"
}

@test "run script's usage" {
    run rke2-setup.sh -h
}

@test "run script" {
    run rke2-setup.sh
}

@test "verify kubectl get nodes works" {
    kubectl get nodes
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify kubectl get pods works" {
    kubectl get pods -A
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}