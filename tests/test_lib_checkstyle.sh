#!/bin/bash
# https://github.com/b9swift/CI-System
# Copyright (c) 2024 BB9z, MIT License

if [ -z "$B9_ROOT" ]; then
    B9_ROOT="$(dirname "${BASH_SOURCE:-$_}")/.."
fi
. "$B9_ROOT/lib/checkstyle.sh"
. "$B9_ROOT/lib/log.sh"

testCreateWithXcodebuildLog() {
    input=$(cat <<-EOF
/file.swift:62:13: warning: message's'
/objc.m:28:51: warning: 'xxx' is deprecated: first deprecated in iOS 13.0 - xx [-Wdeprecated-declarations]
/some others.swift:33:44: error: [err] <msg>
}
other contents...
EOF
    )
    output=$(echo "$input" | checkstyleFromXcodebuild)

    expected=$(cat <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<checkstyle version="4.3">
  <file name="/file.swift">
    <error line="62" column="13" severity="warning" message="message's'" source="xcode"/>
  </file>
  <file name="/objc.m">
    <error line="28" column="51" severity="warning" message="'xxx' is deprecated: first deprecated in iOS 13.0 - xx [-Wdeprecated-declarations]" source="xcode"/>
  </file>
  <file name="/some others.swift">
    <error line="33" column="44" severity="error" message="[err] &lt;msg&gt;" source="xcode"/>
  </file>
</checkstyle>
EOF
    )
    assertEquals "Not match, output:\n$output" "$expected" "$output"
}

testCreatWithXcbeautifyLog() {
    input=$(cat <<-EOF
[!] /dir/some file:0:1: missing '@end'

[x] /fileB.x:12:345: symbol <"&">

other contents...
EOF
    )
    output=$(echo "$input" | checkstyleFromXcbeautify)

    expected=$(cat <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<checkstyle version="4.3">
  <file name="/dir/some file">
    <error line="0" column="1" severity="warning" message="missing '@end'" source="xcode"/>
  </file>
  <file name="/fileB.x">
    <error line="12" column="345" severity="error" message="symbol &lt;&quot;&amp;&quot;&gt;" source="xcode"/>
  </file>
</checkstyle>
EOF
    )
    assertEquals "Not match, output:\n$output" "$expected" "$output"
}
