#!/bin/zsh

# Check if a variable is empty or 0 or false
#
# Return: 0 if variable is not empty or 0 or false
#
# Usage:
#   if [[ $(check_var "$test_var") == 0 ]]; then
#       echo "Variable is not 0, false, or empty"
#   else
#       echo "Variable is 0, false, or empty"
#   fi
check_var() {
    local var_value="$1"
    if [[ -z "$var_value" || "$var_value" == "0" || "${var_value:l}" == "false" ]]; then
        echo "1"
    else
        echo "0"
    fi
}
