# B9CI - CI Toolkit for Apple Development

## Tools

* pod_install
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
