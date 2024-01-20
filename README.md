# B9CI - CI Toolkit for Apple Development

## Tools

### build-ios

Build iOS target.

Environment variables:

* Supports [xcCommand](#xcCommand) variables.
* `CI_CHECK_STYLE_FILE`: Export checkstyle.xml to this path.

### check-result

Environment variables:

* `CI_XCODE_WARNING_IGNORE_TYPES`: Ignore warning types, separated by comma. eg. `"No-usage,Deprecations,Documentation Issue"`
* `CI_XCODE_WARNING_LIMIT`: Limit warning count. eg. `100`

### fetch-mr

Fetch merge request.

Environment variables:

* `CI_CHANGE_LIST_PATH`: Save changed files list to this path.
* `CI_GIT_MR_BRANCH`: Merge request branch name.

### pod-install

Smart CocoaPods install.

Environment variables:

* `CI_POD_INSTALL_LOG_FILE`: Path to the log file. Default: `build/pod_install.log`

## Common Variables

### xcCommand

Inputs:

- `XC_WORKSPACE`, workspace file path.
- `XC_PROJECT`, project file path.
- `XC_SCHEME`, scheme name.
- `XC_CLEAN`, set to `true` to clean before executing the action.
- `XC_CONFIGURATION`, build configuration, eg. `Debug`/`Release`/...
- `XC_DERIVED_DATA`, the xcodebuild command derivedDataPath parameter, defaults to `build/DerivedData`, set to an empty string or `0` or `false` to disable customization.
- `XC_DESTINATION`, target device, value can be the full parameter or abbreviations like `mac`, `ios`, `watchos`, `tvos`.
- `XC_DISABLE_CODE_SIGNING`, set to `true` to disable code signing.
- `XC_RESULT_BUNDLE`, path to xcresult bundle.
- `XC_LOG_FILE`, path to log file.
- `XC_BEAUTIFY`, set to `true` to format output using xcbeautify.

Outputs:

- `CI_XCBEATIFY_USED`, whether xcbeautify is actually used.

## Run Tests

[shunit2](https://github.com/kward/shunit2) required. You can install it via Homebrew.

```zsh
$ ./run_tests

# or run a specific test
$ shunit2 tests/test_lib_fundation.sh
```
