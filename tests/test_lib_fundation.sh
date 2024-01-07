#!/bin/bash

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
