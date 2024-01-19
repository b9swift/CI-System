#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi
. "$B9_ROOT/lib/xccommand.sh"

# mocks
xcodebuild() {
    # tCount="$#"
    echo "[$@]"
    # logInfo "tcount=$tCount"
    return $#
}
# End: mocks

tearDown() {
    xcCommandParametersRestAll
}

testNoAction() {
    result=$(xcCommand)
    assertEquals "status:" $? 1
    assertEquals "Should no command be executed" "" "$result"
}

testSimpleBuild() {
    XC_DERIVED_DATA=0
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 1
    assertEquals "parameters:" "[build]" "$result"
}

testProjectParameters() {
    XC_WORKSPACE="a 1"
    XC_PROJECT="b 2"
    XC_SCHEME="c 3"
    XC_CONFIGURATION="d 4"
    XC_DERIVED_DATA=0
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 9
    assertEquals "parameters:" "[-workspace a 1 -project b 2 -scheme c 3 -configuration d 4 build]" "$result"
}

testDerivedData() {
    unset XC_DERIVED_DATA
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-derivedDataPath build/DerivedData build]" "$result"

    XC_DERIVED_DATA=""
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 1

    XC_DERIVED_DATA=0
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 1

    XC_DERIVED_DATA="1"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-derivedDataPath 1 build]" "$result"
}

testDestination() {
    XC_DERIVED_DATA=0
    XC_DESTINATION="ios"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-destination generic/platform=iOS build]" "$result"

    XC_DESTINATION="mac"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-destination generic/platform=macOS build]" "$result"

    XC_DESTINATION="watchos"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-destination generic/platform=watchOS build]" "$result"

    XC_DESTINATION="tvos"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-destination generic/platform=tvOS build]" "$result"

    XC_DESTINATION="custom"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-destination custom build]" "$result"
}

testDisableCodeSigning() {
    XC_DERIVED_DATA=0
    XC_DISABLE_CODE_SIGNING="1"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 2
    assertEquals "parameters:" "[CODE_SIGNING_ALLOWED=NO build]" "$result"
}

testResultBundle() {
    XC_DERIVED_DATA=0
    XC_RESULT_BUNDLE="xcResult"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 3
    assertEquals "parameters:" "[-resultBundlePath xcResult build]" "$result"
}

testClean() {
    XC_CLEAN="1"
    result=$(xcCommand build)
    assertEquals "parameters count:" $? 4
    assertEquals "parameters:" "[-derivedDataPath build/DerivedData clean build]" "$result"
}
