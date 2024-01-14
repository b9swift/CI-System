# B9CI - CI Toolkit for Apple Development

## Tools

### fetch_mr

Fetch merge request.

Environment variables:

* `CI_CHANGE_LIST_PATH`: Save changed files list to this path.
* `CI_GIT_MR_BRANCH`: Merge request branch name.

### pod_install

Smart CocoaPods install.

Environment variables:

* `CI_POD_INSTALL_LOG_FILE`: Path to the log file. Default: `build/pod_install.log`

## Run Tests

Install [shunit2](https://github.com/kward/shunit2) first.

```zsh
$ ./run_tests

# or run a specific test
$ shunit2 tests/test_lib_fundation.sh
```
