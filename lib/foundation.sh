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
checkVar() {
    local var_value="$1"
    if [[ -z "$var_value" || "$var_value" == "0" || "${var_value:l}" == "false" ]]; then
        echo "1"
    else
        echo "0"
    fi
}

# Pass in a file path, create its parent folder if necessary, and delete the file
prepeareResultFile() {
    mkdir -p "$(dirname "$1")"
    if [ -e "$1" ]; then
        rm -r "$1"
    fi
}
