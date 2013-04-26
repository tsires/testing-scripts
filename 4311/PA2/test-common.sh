#!/bin/bash
# Common testing functions

# Print test message
check() {
	printf '%s ... ' "$1" >&2
	return 0
}

# Print failure message
fail() {
	printf 'fail\n' >&2
	while [ "$#" -ne 0 ]; do
		printf '  %s\n' "$1" >&2
		shift
	done
	return 1
}

# Print success message
pass() {
	printf 'pass\n' >&2
	return 0
}

# Check for missing directory structure
check_missing() {
	for f in ./*; do
		if [ -d "$f" ]; then
			return 0
		fi
	done
	fail 'No directory structure present'
	return 1
}

# Check that all required directories exist
check_dirs() {
	while [ "$#" -ne 0 ]; do
		if [ -d "$1" ]; then
			shift
			continue
		else
			fail 'Directory missing:' "  $1"
			shift
			return 1
		fi
	done
	return 0
}

# Check that all required classes exist
# TODO: Make a less superficial check that considers the file contents as well
check_names() {
	unset _MISSING
	while [ "$#" -ne 0 ]; do
		if [ -n "$(find . -name "${1}.java")" ]; then
			shift
		else
			if [ -n "$_MISSING" ]; then 
				_MISSING="${_MISSING}, ${1}"
			else
				_MISSING="$1"
			fi
			shift
		fi
	done
	if [ -n "$_MISSING" ]; then
		fail 'Class(es) missing:' "  $_MISSING"
		unset _MISSING
		return 1
	fi
	return 0
}

# Check that each class is packaged properly
check_package() {
	if [ -n "$(find . -name '*.java' -exec grep -L "package ${1};" '{}' '+')" ]; then
		# Print a comma-separated list of filenames which don't have the needed package line
		fail 'Class(es) not packaged:' "  $(find . -name '*.java' -exec grep -L 'package csci4311.nc;' '{}' '+' | sed -n 's,\./\(.*\)\.java,\1,;1h;1!H;${g;s,/,.,g;s/\n/, /g;p}')"
		return 1
	fi
	return 0
}

