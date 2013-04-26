#!/bin/bash
# Test client half of CSCI 4311 PA1
# Run this second, from root directory of student
HOST=${1:-'localhost'}
PORT=${2:-'1234'}

# Test upload
printf 'Testing receive from server on port %d...\n' "$PORT" >&2
java csci4311.nc.NetcatUDPClient $HOST $PORT
printf 'Receive from server complete.\n' >&2

# Test download
printf 'Testing send from client on port %d...\n' "$((++PORT))" >&2
java csci4311.nc.NetcatUDPClient $HOST $PORT <<<$'testdata1\ntestdata2\ntestdata3'
printf 'Send from client complete.\n' >&2

