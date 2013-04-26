#!/bin/bash
# Test packaging of CSCI 4311 PA2
# Run from root directory of student

# Include common functions
source "$(dirname "$0")/test-common.sh"

# Directory structure
check 'Checking directory structure' && check_missing && check_dirs 'csci4311/nc/' && pass
# Class naming
check 'Checking class names' && check_names 'NetcatServer' 'NetcatClient' 'NetcatExec' 'NetcatProxy' 'NetcatMulticast' && pass
# Packaging
check 'Checking packaging' && check_package 'csci4311.nc' && pass

