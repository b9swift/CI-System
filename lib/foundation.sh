#!/bin/zsh
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

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

# Show progress dots
#
# Usage：
# xcodebuild ... 2>&1 | showProgress
showProgress() {
    local last_print_time=$(date +%s)
    local -i dots=0
    while read line; do
        local current_time=$(date +%s)
        if [[ $((current_time - last_print_time)) -lt 1 ]]; then
            continue
        elif [[ $((current_time - last_print_time)) -ge 3 ]]; then
            printf "\n"
            dots=0
        fi

        last_print_time=$current_time

        if [[ $dots -lt 80 ]]; then
            printf "."
            dots+=1
        fi
    done

    printf "\n"
}
