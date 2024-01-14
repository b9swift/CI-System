#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi
. "$B9_ROOT/lib/foundation.sh"

testCheckVar() {
    result=$(checkVar "test")
    assertEquals "Expected 0 for non-empty string" "0" "$result"

    result=$(checkVar "")
    assertEquals "Expected 1 for empty string" "1" "$result"

    result=$(checkVar "0")
    assertEquals "Expected 1 for string '0'" "1" "$result"

    result=$(checkVar "false")
    assertEquals "Expected 1 for string 'false'" "1" "$result"
}

testPrepeareResultFile() {
    # Test case 1: File path with existing parent folder
    filePath="tests/result.txt"
    touch "$filePath"
    prepeareResultFile "$filePath"
    assertFalse "Expected file to be deleted" "[ -e $filePath ]"

    # Test case 2: File path with non-existing parent folder
    noExistingFolder="tests/non-existing/folder"
    rm -r "tests/non-existing"
    assertFalse "No directory" "[ -d $noExistingFolder ]"

    filePath="$noExistingFolder/result.txt"
    prepeareResultFile "$filePath"
    assertTrue "Expected parent folder to be created" "[ -d $noExistingFolder ]"
    assertFalse "Expected file to be deleted" "[ -e $filePath ]"
    rm -r "tests/non-existing"
}
