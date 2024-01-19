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
    local last_print_time=0
    local -i dots=0
    while read line; do
        local current_time=$(date +%s)
        if [[ $((current_time - last_print_time)) -lt 1 ]]; then
            continue
        elif [[ $dots -gt 0 ]]; then
            if [[ $dots -ge 80 || $((current_time - last_print_time)) -ge 3 ]]; then
                printf "\n"
                dots=0
            fi
        fi

        last_print_time=$current_time
        printf "."
        dots+=1
    done

    printf "\n"
}
