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
    "XC_CONFIGURATION"
    "XC_RESULT_BUNDLE"
    "XC_DESTINATION"
    "XC_CLEAN"
    "XC_DISABLE_CODE_SIGNING"
    "XC_BEAUTIFY"
)

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
# - XC_CONFIGURATION, build configuration, eg. Debug/Release/...
# - XC_DESTINATION, target device, value can be the full parameter or abbreviations like mac, ios, watchos, tvos
# - XC_RESULT_BUNDLE, path to xcresult bundle
# - XC_CLEAN, set to true to clean before executing the action
# - XC_DISABLE_CODE_SIGNING, set to true to disable code signing
# - XC_BEAUTIFY, set to true to format output using xcbeautify
#
xcCommand() {
    local command=("xcodebuild")
    if [[ -z "${1:-}" ]]; then
        logError "xcCommand: no action specified"
        return 1
    fi
    xcAction=$1

    if [[ -n "${XC_WORKSPACE:-}" ]]; then
        command+=("-workspace" "${XC_WORKSPACE}")
    fi
    if [[ -n "${XC_PROJECT:-}" ]]; then
        command+=("-project" "${XC_PROJECT}")
    fi
    if [[ -n "${XC_SCHEME:-}" ]]; then
        command+=("-scheme" "${XC_SCHEME}")
    fi
    if [[ -n "${XC_CONFIGURATION:-}" ]]; then
        command+=("-configuration" "${XC_CONFIGURATION}")
    fi

    if [[ -n "${XC_DESTINATION:-}" ]]; then
        if [[ "${XC_DESTINATION}" == "mac" ]]; then
            command+=("-destination" "generic/platform=macOS")
        elif [[ "${XC_DESTINATION}" == "ios" ]]; then
            command+=("-destination" "generic/platform=iOS")
        elif [[ "${XC_DESTINATION}" == "watchos" ]]; then
            command+=("-destination" "generic/platform=watchOS")
        elif [[ "${XC_DESTINATION}" == "tvos" ]]; then
            command+=("-destination" "generic/platform=tvOS")
        else
            command+=("-destination" "${XC_DESTINATION}")
        fi
    fi

    if [[ -n "${XC_RESULT_BUNDLE:-}" ]]; then
        command+=("-resultBundlePath" "${XC_RESULT_BUNDLE}")
    fi

    if [[ $(checkVar "${XC_DISABLE_CODE_SIGNING:-}") == 0 ]]; then
        command+=("CODE_SIGNING_ALLOWED=NO")
    fi

    if [[ $(checkVar "${XC_CLEAN:-}") == 0 ]]; then
        command+=("clean")
    fi
    command+=("${xcAction}")

    local outputCommand=()
    if [[ $(checkVar "${XC_BEAUTIFY:-}") == 0 ]]; then
        if ! command -v xcbeautify &> /dev/null; then
            logWarning "xcCommand: xcbeautify not found, ignore XC_BEAUTIFY."
        else
            outputCommand+=("xcbeautify")
            if ! $_B9_LIB_LOG_COLOR_SUPPORTED_; then
                outputCommand+=("--disable-colored-output")
            elif [[ -n "${XC_LOG_FILE:-}" ]]; then
                outputCommand+=("--disable-colored-output")
            fi
            if [[ $(checkVar "${GITHUB_ACTIONS:-}") == 0 ]]; then
                outputCommand+=("--renderer" "github-actions")
            fi
        fi
    fi

    # xcCommandParametersPrint
    if [[ -n "${outputCommand}" ]]; then
        logInfo "xcCommand: ${command[*]} | ${outputCommand[*]}"
        "${command[@]}" | "${outputCommand[@]}"
    else
        logInfo "xcCommand: ${command[*]}"
        "${command[@]}"
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
