#!/bin/zsh
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

# include once
if [[ -n "${_B9_LIB_CHECKSTYLE_INCLUDED_:-}" ]]; then
    return
fi
readonly _B9_LIB_CHECKSTYLE_INCLUDED_=true

# Convert xcodebuild log to checkstyle.xml
#
# Usage:
#   xcodebuild ... | checkstyleFromXcodebuild > checkstyle.xml
#   # OR
#   checkstyleFromXcodebuild < "build/xc-build.log"
checkstyleFromXcodebuild() {
    awk -F ":" '
    BEGIN {
        print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        print "<checkstyle version=\"4.3\">"
    }
    function record(file, line, column, severity, message) {
        sub(/^ /, "", message)
        gsub(/&/, "\\&amp;", message)
        gsub(/</, "\\&lt;", message)
        gsub(/>/, "\\&gt;", message)
        gsub(/\"/, "\\&quot;", message)
        print "  <file name=\"" file "\">"
        print "    <error line=\"" line "\" column=\"" column "\" severity=\"" severity "\" message=\"" message "\" source=\"xcode\"/>"
        print "  </file>"
    }
    /^\/.{5,999}:[0-9]{1,8}:[0-9]{1,7}: warning: / {
        msg = $5
        for(i=6; i<=NF; i++) {
            msg = msg ":" $i
        }
        record($1, $2, $3, "warning", msg)
    }
    /^\/.{5,999}:[0-9]{1,8}:[0-9]{1,7}: error: / {
        msg = $5
        for(i=6; i<=NF; i++) {
            msg = msg ":" $i
        }
        record($1, $2, $3, "error", msg)
    }
    END {
        print "</checkstyle>"
    }'
}

# Convert xcbeautify log to checkstyle.xml
#
# Usage:
#   xcodebuild ... | xcbeautify | checkstyleFromXcbeautify > checkstyle.xml
#   # OR
#   checkstyleFromXcbeautify < "build/xc-build.log"
checkstyleFromXcbeautify() {
    awk -F ":" '
    BEGIN {
        print "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        print "<checkstyle version=\"4.3\">"
    }
    function record(file, line, column, severity, message) {
        sub(/^ /, "", message)
        gsub(/&/, "\\&amp;", message)
        gsub(/</, "\\&lt;", message)
        gsub(/>/, "\\&gt;", message)
        gsub(/\"/, "\\&quot;", message)
        print "  <file name=\"" file "\">"
        print "    <error line=\"" line "\" column=\"" column "\" severity=\"" severity "\" message=\"" message "\" source=\"xcode\"/>"
        print "  </file>"
    }
    /^\[!\] {1,4}\/.{5,999}:[0-9]{1,8}:[0-9]{1,7}/ {
        sub(/^\[!\] {1,4}/, "", $1)
        msg = $4
        for(i=5; i<=NF; i++) {
            msg = msg ":" $i
        }
        record($1, $2, $3, "warning", msg)
    }
    /^\[x\] {1,4}\/.{5,999}:[0-9]{1,8}:[0-9]{1,7}/ {
        sub(/^\[x\] {1,4}/, "", $1)
        msg = $4
        for(i=5; i<=NF; i++) {
            msg = msg ":" $i
        }
        record($1, $2, $3, "error", msg)
    }
    END {
        print "</checkstyle>"
    }'
}
