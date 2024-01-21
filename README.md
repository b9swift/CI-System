# B9CI - CI Toolkit for Apple Development

[![CI](https://github.com/b9swift/CI-System/actions/workflows/ci.yml/badge.svg)](https://github.com/b9swift/CI-System/actions/workflows/ci.yml)

## Tools

### build-ios

Build an iOS target.

Environment variables:

* Supports [xcCommand](#xcCommand) variables.
* `CI_CHECK_STYLE_FILE`: Export checkstyle.xml to this path.
* `XC_ANALYZE`, set to `true` or `1` to perform static analysis during the build. By default, this is disabled.

### check-result

This tool parses the Xcode result bundle and performs certain actions. It can:

* List build warnings and errors, including support for static analysis results.
* Limit build warnings to a specified threshold.
* Provide a view of issue category statistics.
* Print a summary of the tests.
* Export build issues to a checkstyle.xml report file.

See [command usage](https://github.com/b9swift/CI-System/blob/main/check-result#L10) for more details.

### fetch-mr

Fetch merge request.

Environment variables:

* `CI_CHANGE_LIST_PATH`: Saves the list of changed files to this path.
* `CI_GIT_MR_BRANCH`: The name of the merge request branch.

### pod-install

Performs a smart CocoaPods installation.

Environment variables:

* `CI_POD_INSTALL_LOG_FILE`: Path to the log file. Default: `build/pod_install.log`

## Common Variables

### xcCommand

<!-- Link here: xccommand.sh -->

Inputs environment variables:

- `XC_WORKSPACE`, the path to the workspace file.
- `XC_PROJECT`, the path to the project file.
- `XC_SCHEME`, the name of the scheme.
- `XC_CLEAN`, set to `true` or `1` to clean before executing the action.
- `XC_CONFIGURATION`, build configuration, eg. `Debug`/`Release`/...
- `XC_DERIVED_DATA`, the xcodebuild command derivedDataPath parameter, defaults to `build/DerivedData`, set to an empty string or `0` or `false` to disable customization.
- `XC_DESTINATION`, target device, value can be the full parameter or abbreviations like `mac`, `ios`, `watchos`, `tvos`.
- `XC_DISABLE_CODE_SIGNING`, set to `true` or `1` to disable code signing.
- `XC_RESULT_BUNDLE`, path to xcresult bundle.
- `XC_LOG_FILE`, path to log file.
- `XC_BEAUTIFY`, set to `true` or `1` to format output using xcbeautify.

## Run Tests

[shunit2](https://github.com/kward/shunit2) is required. You can install it via Homebrew.

```zsh
$ ./run_tests

# or run a specific test
$ shunit2 tests/test_lib_fundation.sh
```
