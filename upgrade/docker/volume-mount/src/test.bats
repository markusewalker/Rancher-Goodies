#!/bin/bash

setup() {
    load "../test/test_helper/bats-support/load"
    load "../test/test_helper/bats-assert/load"
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"
}

@test "run script's usage" {
    run mount-upgrade.sh -h
}

@test "run script" {
    run mount-upgrade.sh
}

@test "verify backup was created" {
    find . -name "rancher-data-v*"
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}

@test "verify Rancher is running" {
    docker ps | grep "rancher/rancher"
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}