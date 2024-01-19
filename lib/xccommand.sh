#!/bin/zsh
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

# include once
if [[ -n "${_B9_LIB_XCCOMMAND_INCLUDED_:-}" ]]; then
    return
fi
readonly _B9_LIB_XCCOMMAND_INCLUDED_=true

if [ -n "${BASH_VERSION:-}" ]; then
    _lib_="$(dirname "${BASH_SOURCE[0]}")"
else
    _lib_="${${(%):-%x}:A:h}"
fi
. "$_lib_/foundation.sh"
. "$_lib_/log.sh"

readonly _xcParameterList=(
    "XC_WORKSPACE"
    "XC_PROJECT"
    "XC_SCHEME"
    "XC_CLEAN"
    "XC_CONFIGURATION"
    "XC_DERIVED_DATA"
    "XC_DESTINATION"
    "XC_DISABLE_CODE_SIGNING"
    "XC_RESULT_BUNDLE"
    "XC_REDIRECT_STDERR"
    "XC_LOG_FILE"
    "XC_BEAUTIFY"
)

export _XC_COMMANDS=()

# Wrapper for xcodebuild command
# 
# Usage:
# xcCommand <action>
# 
# Other parameters are passed through environment variables, supported variables are:
#
# - XC_WORKSPACE, workspace file path
# - XC_PROJECT, project file path
# - XC_SCHEME, scheme name
# - XC_CLEAN, set to true to clean before executing the action
# - XC_CONFIGURATION, build configuration, eg. Debug/Release/...
# - XC_DESTINATION, target device, value can be the full parameter or abbreviations like mac, ios, watchos, tvos
# - XC_DISABLE_CODE_SIGNING, set to true to disable code signing
# - XC_RESULT_BUNDLE, path to xcresult bundle
# - XC_REDIRECT_STDERR, wheather redirect stderr to stdout
# - XC_LOG_FILE, path to log file
# - XC_BEAUTIFY, set to true to format output using xcbeautify
#
xcCommand() {
    if [[ -z "${1:-}" ]]; then
        logError "xcCommand: no action specified"
        return 1
    fi
    export _xcAction="$1"

    # if [[ $(checkVar "${XC_REDIRECT_STDERR:-}") == 0 ]]; then
    #     xcParts+=("2>&1")
    # fi

    _xcChain3
}

_xcChain1() {
    local xcParts=("xcodebuild")

    if [[ -n "${XC_WORKSPACE:-}" ]]; then
        xcParts+=("-workspace" "${XC_WORKSPACE}")
    fi
    if [[ -n "${XC_PROJECT:-}" ]]; then
        xcParts+=("-project" "${XC_PROJECT}")
    fi
    if [[ -n "${XC_SCHEME:-}" ]]; then
        xcParts+=("-scheme" "${XC_SCHEME}")
    fi
    if [[ -n "${XC_CONFIGURATION:-}" ]]; then
        xcParts+=("-configuration" "${XC_CONFIGURATION}")
    fi
    if [[ $(checkVar "${XC_DERIVED_DATA-1}") == 0 ]]; then
        xcParts+=("-derivedDataPath" "${XC_DERIVED_DATA-"build/DerivedData"}")
    fi

    if [[ -n "${XC_DESTINATION:-}" ]]; then
        if [[ "${XC_DESTINATION}" == "mac" ]]; then
            xcParts+=("-destination" "generic/platform=macOS")
        elif [[ "${XC_DESTINATION}" == "ios" ]]; then
            xcParts+=("-destination" "generic/platform=iOS")
        elif [[ "${XC_DESTINATION}" == "watchos" ]]; then
            xcParts+=("-destination" "generic/platform=watchOS")
        elif [[ "${XC_DESTINATION}" == "tvos" ]]; then
            xcParts+=("-destination" "generic/platform=tvOS")
        else
            xcParts+=("-destination" "${XC_DESTINATION}")
        fi
    fi

    if [[ -n "${XC_RESULT_BUNDLE:-}" ]]; then
        xcParts+=("-resultBundlePath" "${XC_RESULT_BUNDLE}")
    fi

    if [[ $(checkVar "${XC_DISABLE_CODE_SIGNING:-}") == 0 ]]; then
        xcParts+=("CODE_SIGNING_ALLOWED=NO")
    fi

    if [[ $(checkVar "${XC_CLEAN:-}") == 0 ]]; then
        xcParts+=("clean")
    fi
    xcParts+=("${_xcAction}")

    _XC_COMMANDS=("${xcParts[@]}" "${_XC_COMMANDS[@]}")
    logInfo "xcCommand: ${_XC_COMMANDS[*]}"
    "${xcParts[@]}"
}

_xcChain2() {
    local beautyParts=()
    if [[ $(checkVar "${XC_BEAUTIFY:-}") == 0 ]]; then
        if ! command -v xcbeautify &> /dev/null; then
            logWarning "xcCommand: xcbeautify not found, ignore XC_BEAUTIFY."
        else
            beautyParts+=("xcbeautify")
            if ! $_B9_LIB_LOG_COLOR_SUPPORTED_; then
                beautyParts+=("--disable-colored-output")
            elif [[ -n "${XC_LOG_FILE:-}" ]]; then
                beautyParts+=("--disable-colored-output")
            fi
            if [[ $(checkVar "${GITHUB_ACTIONS:-}") == 0 ]]; then
                beautyParts+=("--renderer" "github-actions")
            fi
        fi
    fi

    if [[ -n "${beautyParts}" ]]; then
        _XC_COMMANDS=("|" "${beautyParts[@]}" "${_XC_COMMANDS[@]}")
        _xcChain1 | "${beautyParts[@]}"
    else
        _xcChain1
    fi
}

_xcChain3() {
    local logParts=()
    if [[ -n "${XC_LOG_FILE:-}" ]]; then
        logParts+=("tee" "${XC_LOG_FILE}")
    fi

    if [[ -n "${logParts}" ]]; then
        _XC_COMMANDS=("|" "${logParts[@]}" "${_XC_COMMANDS[@]}")
        _xcChain2 | "${logParts[@]}"
    else
        _xcChain2
    fi
}

# Print xcCommand environment variables for debugging
xcCommandParametersPrint() {
    for param in "${_xcParameterList[@]}"; do
        logInfo "$param = ${(P)param:-<nil>}"
    done
}

# Reset all xcCommand environment variables
xcCommandParametersRestAll() {
    for param in "${_xcParameterList[@]}"; do
        if [ -n "${BASH_VERSION:-}" ]; then
            if [[ -n "${!param:-}" ]]; then
                logWarning "Unset $param."
                unset "$param"
            fi
        else
            if [[ -n "${(P)param:-}" ]]; then
                logWarning "Unset $param."
                unset "$param"
            fi
        fi
    done
}
