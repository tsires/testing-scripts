#!/bin/bash
# Testing functions for testing CSCI 4311 PA3 (REST server)

# source this script to load functions into environment for manual testing

# Fix JSON (Fixes JSON meeting assignment specs to be valid JSON)
# Also remove appended response code
fix_json() {
	# { [ ... ] } --> [ ... ]
	local _FIXARRAYS='s/{\s*\(\[.*\]\)\s*}/\1/g;'
	# { key: ... } --> { "key": ... }
	local _FIXOBJECTS='s/\([a-zA-Z0-9]\+\)\s*:/"\1":/g;'
	head -n -1 | sed -n -e '1h;1!H;${g;s/\n/ /g;'"${_FIXARRAYS}${_FIXOBJECTS}"'p;};'
}

# URLencode string (or at least whitespace, /, ?, &, and =)
urlencode() {
	sed -e 's/ /%20/g; s/\t/%09/g; s,/,%2f,g; s/?/%3f/g; s/&/%26/g; s/=/%3d/g;'
}

# Check appended response code
expect_error() {
	[ "$(tail -n 1)" = "${1}" ]
}

# Expect an empty object or array
expect_empty() {
	[ "$(jshon -Q -l)" = "0" ]
}

# Expect an object with $1 elements
expect_object_length() {
	[ "$(jshon -Q -t -l)" = $'object\n'"${1}" ]
}

# Expect an array with $1 elements
expect_array_length() {
	[ "$(jshon -Q -t -l)" = $'array\n'"${1}" ]
}

# Expect an array or object to contain $1:$2 as a key-value pair (numeric keys for arrays)
# If more than 2 parameters are given, extract from nested objects
expect_key_value() {
	# Build jshon -Q param list
	local -a _JSHON_PARAMS=()
	while [ "$#" -gt 1 ]; do
		_JSHON_PARAMS+=("-e" "${1}")
		shift
	done
	[ "$(jshon -Q "${_JSHON_PARAMS[@]}" -u)" = "${1}" ]
}

# Index users
user_index() {
	curl -w '\n%{http_code}\n' -sS 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/users'
}

# Show user
user_show() {
	curl -w '\n%{http_code}\n' -sS 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/user/'"${1}"
}

# Create user
user_create() {
	curl -w '\n%{http_code}\n' -sS -X PUT 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/user/'"${1}"'?name='"$(urlencode <<<"${2}")"
}

# Delete user
user_delete() {
	curl -w '\n%{http_code}\n' -sS -X DELETE 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/user/'"${1}"
}

# Index topics
topic_index() {
	curl -w '\n%{http_code}\n' -sS 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/topics'
}

# Show topic
topic_show() {
	curl -w '\n%{http_code}\n' -sS 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/topic/'"${1}"
}

# Delete topic
topic_delete() {
	curl -w '\n%{http_code}\n' -sS -X DELETE 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/topic/'"${1}"
}

# Create message
message_create() {
	curl -w '\n%{http_code}\n' -sS -X POST -d 'message='"${2}" 'http://'"${TEST_HOST:-localhost}"':'"${TEST_PORT:-1234}"'/message/'"${1}"
}

