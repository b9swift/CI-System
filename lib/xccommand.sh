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
    "XC_ANALYZE"
    "XC_CLEAN"
    "XC_CONFIGURATION"
    "XC_DERIVED_DATA"
    "XC_DESTINATION"
    "XC_DISABLE_CODE_SIGNING"
    "XC_RESULT_BUNDLE"
    "XC_LOG_FILE"
    "XC_BEAUTIFY"
)

export _XC_COMMANDS=()

# Wrapper for xcodebuild command
# 
# Usage:
# xcCommand <action>
# 
# Other parameters are passed through environment variables, see:
# https://github.com/b9swift/CI-System#xccommand
xcCommand() {
    if [[ -z "${1:-}" ]]; then
        logError "xcCommand: no action specified"
        return 1
    fi
    export _xcAction="$1"

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
        xcParts+=("-destination" "$(_xcCompleteDestination)")
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

_xcCompleteDestination() {
    case "$XC_DESTINATION" in
        "mac")
            echo "generic/platform=macOS";;
        "ios")
            echo "generic/platform=iOS";;
        "ios-simulator")
            echo "$(_xcAutoSelecteSimulator "iOS Simulator")";;
        "watchos")
            echo "generic/platform=watchOS";;
        "watchos-simulator")
            echo "$(_xcAutoSelecteSimulator "watchOS Simulator")";;
        "tvos")
            echo "generic/platform=tvOS";;
        "tvos-simulator")
            echo "$(_xcAutoSelecteSimulator "tvOS Simulator")";;
        *)
            echo "$XC_DESTINATION";;
    esac
}

_xcAutoSelecteSimulator() {
    logInfo "Detecting simulator for $1..."
    local selectCommand=("xcodebuild" "-showdestinations")
    if [[ -n "${XC_WORKSPACE:-}" ]]; then
        selectCommand+=("-workspace" "${XC_WORKSPACE}")
    fi
    if [[ -n "${XC_PROJECT:-}" ]]; then
        selectCommand+=("-project" "${XC_PROJECT}")
    fi
    if [[ -n "${XC_SCHEME:-}" ]]; then
        selectCommand+=("-scheme" "${XC_SCHEME}")
    fi
    local destList=$("${selectCommand[@]}" | grep "platform:$1" | grep -v ":placeholder")
    local destLast=$(echo "$destList" | tail -1)
    local destLastID=$(echo "$destLast" | awk -F 'id:' '{print $2}' | awk -F ',' '{print $1}')
    local destLastName=$(echo "$destLast" | awk -F 'name:' '{print $2}' | awk -F '}' '{print $1}')
    logWarning "Auto select simulator: $destLastName($destLastID)."
    echo "platform=$1,id=$destLastID"
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
