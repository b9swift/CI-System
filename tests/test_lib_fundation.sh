# Description: Tests for lib_fundation.sh

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "$0")/.."
fi
. "$B9_ROOT/lib_fundation.sh"

testCheckVar() {
    result=$(check_var "test")
    assertEquals "Expected 0 for non-empty string" "0" "$result"

    result=$(check_var "")
    assertEquals "Expected 1 for empty string" "1" "$result"

    result=$(check_var "0")
    assertEquals "Expected 1 for string '0'" "1" "$result"

    result=$(check_var "false")
    assertEquals "Expected 1 for string 'false'" "1" "$result"
}
