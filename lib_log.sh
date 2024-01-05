#!/bin/zsh

set -euo pipefail

# include once
if [[ -z "${_B9_LIB_LOG_INCLUDED_:-}" ]]; then
    readonly _B9_LIB_LOG_INCLUDED_=true

    if [[ $(tput colors) -ge 8 ]]; then
        readonly _B9_LIB_LOG_COLOR_SUPPORTED_=true
    else
        readonly _B9_LIB_LOG_COLOR_SUPPORTED_=false
    fi
fi

# 打印一般信息
logInfo() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[32m%s\033[0m\n" "$1" >&2
    else
        echo "$1" >&2
    fi
}

# 打印警告信息
logWarning() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[33m%s\033[0m\n" "$1" >&2
    else
        echo "$1" >&2
    fi
}

# 打印错误信息
logError() {
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[31m%s\033[0m" "$1" >&2
    else
        echo "$1" >&2
    fi
}

# 打印分隔，蓝色背景
logSection() {
    echo "" >&2
    if $_B9_LIB_LOG_COLOR_SUPPORTED_; then
        printf "\033[44m%s\033[0m" "$1" >&2
    else
        echo "$1" >&2
    fi
}
