#!/bin/bash

setup() {
    load "../test/test_helper/bats-support/load"
    load "../test/test_helper/bats-assert/load"
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"
}

@test "run script's usage" {
    run mount-install.sh -h
}

@test "run script" {
    run mount-install.sh
}

@test "verify kubectl is installed" {
    kubectl
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify docker is installed" {
    docker version
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify Rancher container exists" {
    docker ps | grep rancher
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}