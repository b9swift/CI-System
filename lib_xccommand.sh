#!/bin/zsh

set -euo pipefail

. "./lib_log.sh"
. "./lib_fundation.sh"

logInfo "in xccommand.sh"

# include once
if [[ -z "${_B9_LIB_XCCOMMAND_INCLUDED_:-}" ]]; then
    readonly _B9_LIB_XCCOMMAND_INCLUDED_=true

    readonly _xcParameterList=(
        "XC_WORKSPACE"
        "XC_PROJECT"
        "XC_SCHEME"
        "XC_CONFIGURATION"
        "XC_CLEAN"
        "XC_DISABLE_CODE_SIGNING"
        "XC_DRY_RUN"
        "XC_LOG_FILE"
        "XC_BEAUTIFY"
    )
fi

# xcodebuild 命令的封装
# 
# Usage:
# xcCommand <action>
# 
# 其他参数通过环境变量传入，支持的变量有：
#
# - XC_WORKSPACE，工作区文件路径
# - XC_PROJECT，项目文件路径
# - XC_SCHEME，scheme 名称
# - XC_CONFIGURATION，编译配置 Debug/Release/...
# - XC_CLEAN，设置为真时先清理在执行 action
# - XC_DISABLE_CODE_SIGNING，设置为真时禁用签名
# - XC_DRY_RUN，设置为真时 dry-run 模式运行
# - XC_LOG_FILE，日志文件路径
# - XC_BEAUTIFY，设置为真时用 xcbeautify 格式化输出
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

    if [[ $(check_var "${XC_DISABLE_CODE_SIGNING:-}") == 0 ]]; then
        command+=("CODE_SIGNING_ALLOWED=NO")
    fi
    if [[ $(check_var "${XC_DRY_RUN:-}") == 0 ]]; then
        command+=("-dry-run")
    fi

    if [[ $(check_var "${XC_CLEAN:-}") == 0 ]]; then
        command+=("clean")
    fi
    command+=("${xcAction}")

    xcCommandParametersPrint
    # execute command
    logInfo "xcCommand: ${command[*]}"
    "${command[@]}"
}

# 打印 xcCommand 环境变量，用于调试
xcCommandParametersPrint() {
    for param in "${_xcParameterList[@]}"; do
        logInfo "$param = ${(P)param:-<nil>}"
    done
}

# 重置所有 xcCommand 环境变量
xcCommandParametersRestAll() {
    for param in "${_xcParameterList[@]}"; do
        if [[ -n "${(P)param:-}" ]]; then
            logWarning "Unset $param."
            unset "$param"
        fi
    done
}
