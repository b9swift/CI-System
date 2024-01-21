#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi

unsetEnv() {
    unset CI_CHECK_STYLE_FILE
    unset CI_XCODE_ERROR_LIMIT
    unset CI_XCODE_WARNING_IGNORE_TYPES
    unset CI_XCODE_WARNING_LIMIT
    unset XC_PROJECT
    unset XC_RESULT_BUNDLE
    unset XC_WORKSPACE
}

oneTimeSetUp() {
    cd "$B9_ROOT"
    rm -rf .test
    unsetEnv
}

tearDown() {
    unsetEnv
}

testNoBundle() {
    code=0
    output=$(./check-result) || {
        code=$?
    }
    assertEquals 1 $code
    assertContains "XC_RESULT_BUNDLE" "$output"
}

testBundleNotExist() {
    export XC_RESULT_BUNDLE="not-exist"
    code=0
    output=$(./check-result 2>&1) || {
        code=$?
    }
    assertEquals 1 $code
    assertContains "not exist" "$output"
    assertContains "Usage: check-result" "$output"
}

testNoAction() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/AllRight.xcresult"
    code=0
    output=$(./check-result 2>&1) || {
        code=$?
    }
    assertEquals 0 $code
    assertContains "Usage: check-result" "$output"
}

testCheckStyleWithNoEnv() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/HasWarningAndError.xcresult"
    code=0
    output=$(./check-result checkstyle 2>&1) || {
        code=$?
    }
    assertEquals 1 $code
    assertContains "CI_CHECK_STYLE_FILE is required" "$output"
}

testCheckStyleWithNoIssues() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/AllRight.xcresult"
    export CI_CHECK_STYLE_FILE=".test/c1.xml"
    code=0
    output=$(./check-result checkstyle 2>&1) || {
        code=$?
    }
    assertEquals 0 $code
    echo "$output"
    if [[ ! -f "$CI_CHECK_STYLE_FILE" ]]; then
        fail "Checkstyle file should be generated."
    fi

    # should contains no error items
    if grep -q "<error" "$CI_CHECK_STYLE_FILE"; then
        fail "Report file should not contains '<error>'."
    fi
}

testCheckStyleWithIssues() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/HasWarningAndError.xcresult"
    export CI_CHECK_STYLE_FILE=".test/c2.xml"
    code=0
    output=$(./check-result checkstyle 2>&1) || {
        code=$?
    }
    assertEquals 0 $code
    if [[ ! -f "$CI_CHECK_STYLE_FILE" ]]; then
        fail "Checkstyle file should be generated."
    fi

    # should contains error items
    if ! grep -q "<error" "$CI_CHECK_STYLE_FILE"; then
        fail "Report file should contains '<error>'."
    fi
}

testCommandsWithAllRight() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/AllRight.xcresult"
    code=0
    output=$(./check-result listIssues summary) || {
        code=$?
    }
    assertEquals 0 $code
    assertContains "$output" "No issues"
    # echo "$output"
}

testCommandsWithHasWarningAndError() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/HasWarningAndError.xcresult"
    code=0
    output=$(./check-result listIssues summary) || {
        code=$?
    }
    assertEquals 0 $code
    assertContains "$output" "There are: 2 error(s), 2 warning(s)"
    assertContains "$output" "Issues Summary"
    assertContains "$output" ": 4"
    echo "$output"
}
