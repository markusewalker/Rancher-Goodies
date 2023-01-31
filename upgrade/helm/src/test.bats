#!/bin/bash

setup() {
    load "../test/test_helper/bats-support/load"
    load "../test/test_helper/bats-assert/load"
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    PATH="$DIR/../src:$PATH"
}

@test "run script's usage" {
    run upgrade.sh -h
}

@test "run script" {
    run upgrade.sh
}

@test "verify Rancher is running" {
    kubectl -n cattle-system get deploy rancher
    RESULT=$?
    [ "${RESULT}" -eq 0 ]
}