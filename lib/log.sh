#!/bin/zsh

# include once
if [[ -n "${_B9_LIB_LOG_INCLUDED_:-}" ]]; then
    return
fi
readonly _B9_LIB_LOG_INCLUDED_=true

if [[ $(tput colors) -ge 8 ]]; then
    readonly _B9_LIB_LOG_COLOR_SUPPORTED_=true
else
    readonly _B9_LIB_LOG_COLOR_SUPPORTED_=false
fi

# Print general information
logInfo() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[32m%s\033[0m\n" "$1" >&2
    else
        echo "🔵 $1" >&2
    fi
}

# Print warning information
logWarning() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[33m%s\033[0m\n" "$1" >&2
    else
        echo "🟠 $1" >&2
    fi
}

# Print error information
logError() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[31m%s\033[0m" "$1" >&2
    else
        echo "🔴 $1" >&2
    fi
}

# Print section
logSection() {
    echo "" >&2
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[44m%s\033[0m" "$1" >&2
    else
        echo "🟦 $1" >&2
    fi
}
