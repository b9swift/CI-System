#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi

. "$B9_ROOT/lib/xccommand.sh"

unsetEnv() {
    unset CI_CHECK_STYLE_FILE
    xcCommandParametersRestAll
}

oneTimeSetUp() {
    cd "$B9_ROOT"
    unsetEnv
}

setUp() {
    rm -rf .test
    rm -rf build
    export XC_DISABLE_CODE_SIGNING=1
}

tearDown() {
    unsetEnv
}

testProjectNoWarning() {
    export XC_PROJECT="tests/samples/BuildTests.xcodeproj"
    export XC_SCHEME="NoWarning"
    export XC_DESTINATION=mac
    export XC_CLEAN=1
    export XC_BEAUTIFY=0
    unset XC_RESULT_BUNDLE  # should use default
    code=0
    ./build-ios || {
        code=$?
    }

    assertEquals "return code" 0 $code
    if [[ ! -d "build/xc-build.xcresult" ]]; then
        failed "Result bundle file should be generated."
    fi
}

testWorkspaceHasWarning() {
    export XC_WORKSPACE="$B9_ROOT/tests/samples/Tests.xcworkspace"
    export XC_SCHEME="HasWarning"
    export XC_DESTINATION=mac
    export XC_CLEAN=1
    export XC_RESULT_BUNDLE=".test/t2.xcresult"
    export CI_CHECK_STYLE_FILE=".test/t2.xml"
    code=0
    ./build-ios || {
        code=$?
    }

    assertEquals "return code" 0 $code
    if [[ ! -f "$CI_CHECK_STYLE_FILE" ]]; then
        failed "Checkstyle file should be generated."
    fi
    if [[ ! -d "$XC_RESULT_BUNDLE" ]]; then
        failed "Result bundle file should be generated."
    fi
}

testWorkspaceHasError() {
    export XC_WORKSPACE="$B9_ROOT/tests/samples/Tests.xcworkspace"
    export XC_SCHEME="HasError"
    export XC_DESTINATION=mac
    export XC_CLEAN=1
    export XC_RESULT_BUNDLE=".test/t3.xcresult"
    export CI_CHECK_STYLE_FILE=".test/t3.xml"
    code=0
    ./build-ios || {
        code=$?
    }

    assertNotEquals "return code" 0 $code
    if [[ ! -f "$CI_CHECK_STYLE_FILE" ]]; then
        failed "Checkstyle file should be generated."
    fi
    if [[ ! -d "$XC_RESULT_BUNDLE" ]]; then
        failed "Result bundle file should be generated."
    fi
}

testIssuesHighlight() {
    export XC_WORKSPACE="$B9_ROOT/tests/samples/Tests.xcworkspace"
    export XC_SCHEME="HasError"
    export XC_DESTINATION=mac
    export XC_CLEAN=1
    export XC_RESULT_BUNDLE=".test/t4.xcresult"
    export CI_CHECK_STYLE_FILE=".test/t4.xml"
    export CI_ISSUES_HIGHLIGHT_FILE_LIST_PATH="tests/samples/ChangeListHasWarning1.txt"
    code=0
    output=$(./build-ios) || {
        code=$?
    }
    echo ">> $output"

    assertNotEquals "build should fail" 0 $code
    assertContains "$output" "There are: 2 error(s), 3 warning(s)"
    assertContains "$output" "Only 1 issue(s) related to changed files are shown."
}

testAnalyzEnvFlagNotSet() {
    export XC_PROJECT="tests/samples/BuildTests.xcodeproj"
    export XC_SCHEME="ClangAnalyz"
    export XC_DESTINATION=mac
    export XC_ANALYZE=0
    code=0
    output=$(./build-ios) || {
        code=$?
    }

    assertEquals "return code" 0 $code
    assertContains "$output" "No issues."
    assertNotContains "$output" "[A]"
}

testAnalyzNoIssues() {
    export XC_PROJECT="tests/samples/BuildTests.xcodeproj"
    export XC_SCHEME="NoWarning"
    export XC_DESTINATION=mac
    export XC_ANALYZE=1
    code=0
    output=$(./build-ios) || {
        code=$?
    }

    assertEquals "return code" 0 $code
    assertContains "$output" "No issues."
    assertNotContains "$output" "[A]"
}

testAnalyzHasIssues() {
    export XC_PROJECT="tests/samples/BuildTests.xcodeproj"
    export XC_SCHEME="ClangAnalyz"
    export XC_DESTINATION=mac
    export XC_ANALYZE=1
    code=0
    output=$(./build-ios) || {
        code=$?
    }

    assertEquals "return code" 0 $code
    assertContains "$output" "[A]"
    # echo ">> $output"
}

testAnalyzWithWarningLimit() {
    export XC_PROJECT="tests/samples/BuildTests.xcodeproj"
    export XC_SCHEME="HasWarning"
    export XC_DESTINATION=mac
    export CI_XCODE_WARNING_LIMIT=2
    code=0
    output=$(./build-ios) || {
        code=$?
    }

    assertEquals "return code is warning count" 3 $code
    assertContains "$output" "[!]"
    assertContains "$output" "Warning count 3 exceed limit 2"
}
