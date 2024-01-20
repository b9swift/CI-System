#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi

unsetEnv() {
    unset CI_CHECK_STYLE_FILE
    unset CI_XCODE_WARNING_IGNORE_TYPES
    unset CI_XCODE_WARNING_LIMIT
    unset CI_XCODE_ERROR_LIMIT
    unset XC_RESULT_BUNDLE
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
    assertEquals $code 1
    assertContains "$output" "XC_RESULT_BUNDLE"
}

testBundleNotExist() {
    export XC_RESULT_BUNDLE="not-exist"
    code=0
    output=$(./check-result 2>&1) || {
        code=$?
    }
    assertEquals $code 1
    assertContains "$output" "not exist"
    assertContains "$output" "Usage: check-result"
}

testNoAction() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/AllRight.xcresult"
    code=0
    output=$(./check-result 2>&1) || {
        code=$?
    }
    assertEquals $code 0
    assertContains "$output" "Usage: check-result"
}

testCheckStyleWithNoEnv() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/HasWarningAndError.xcresult"
    code=0
    output=$(./check-result checkstyle 2>&1) || {
        code=$?
    }
    assertEquals $code 1
    assertContains "$output" "CI_CHECK_STYLE_FILE is required"
}

testCheckStyleWithNoIssues() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/AllRight.xcresult"
    export CI_CHECK_STYLE_FILE=".test/c1.xml"
    code=0
    output=$(./check-result checkstyle 2>&1) || {
        code=$?
    }
    assertEquals $code 0
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
    assertEquals $code 0
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
    assertEquals $code 0
    # assertContains "$output" "No issues found"
    echo "$output"
}

testCommandsWithHasWarningAndError() {
    export XC_RESULT_BUNDLE="$B9_ROOT/tests/samples/HasWarningAndError.xcresult"
    code=0
    output=$(./check-result listIssues summary) || {
        code=$?
    }
    assertEquals $code 0
    # assertContains "$output" "Found 2 issues"
    # assertContains "$output" "Found 1 error"
    # assertContains "$output" "Found 1 warning"
    echo "$output"
}
