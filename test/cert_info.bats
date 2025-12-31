#!/usr/bin/env bats

setup() {
    # Determine the directory of the script relative to this test file
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    CERT_INFO="$DIR/../extend/cert_info"
    load '../node_modules/bats-support/load'
    load '../node_modules/bats-assert/load'
}

teardown() {
    # No teardown actions needed currently
    true
}

assert_wrong_number_of_arguments() {
    run "$CERT_INFO" "$@"
    assert_failure 1
    assert_output "Fail
Tool cert_info requires three arguments."
}

@test "cert_info fails with too few arguments: 0" {
    assert_wrong_number_of_arguments
}

@test "cert_info fails with too few arguments: 1" {
    assert_wrong_number_of_arguments ica
}

@test "cert_info fails with too few arguments: 1 with spacing" {
    assert_wrong_number_of_arguments "ica 123 9abc"
}

@test "cert_info fails with too few arguments: 2" {
    assert_wrong_number_of_arguments ica expiration
}

@test "cert_info fails with too many arguments: 4" {
    assert_wrong_number_of_arguments ica expiration iso-8601-compact-date extra_arg
}
