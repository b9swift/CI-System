#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi

. "$B9_ROOT/lib/xccommand.sh"

oneTimeSetUp() {
    xcCommandParametersRestAll
}

setUp() {
    cd "$B9_ROOT"
    rm -rf .test
    rm -rf build
    export XC_DISABLE_CODE_SIGNING=1
}

tearDown() {
    xcCommandParametersRestAll
}

testDestinationSimulator() {
    cd "tests/samples/MyLibrary"
    export XC_SCHEME="MyLibrary"
    export XC_DESTINATION=ios-simulator
    output=$(_xcCompleteDestination)
    echo ">> $output"
    assertTrue "should match platform=iOS Simulator,id=<uuid>" "echo $output | grep -E 'platform=iOS Simulator,id=[0-9A-F-]{32,40}'"

    export XC_DESTINATION="tvos-simulator"
    output=$(_xcCompleteDestination)
    echo ">> $output"
    assertTrue "should match platform=tvOS Simulator,id=<uuid>" "echo $output | grep -E 'platform=tvOS Simulator,id=[0-9A-F-]{32,40}'"

    export XC_DESTINATION="watchos-simulator"
    output=$(_xcCompleteDestination)
    echo ">> $output"
    assertTrue "should match platform=watchOS Simulator,id=<uuid>" "echo $output | grep -E 'platform=watchOS Simulator,id=[0-9A-F-]{32,40}'"
}
