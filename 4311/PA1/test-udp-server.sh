#!/bin/bash
# Test server half of CSCI 4311 PA1
# Run this first, from root directory of student
PORT=${1:-'1234'}

# Test upload
printf 'Testing send from server on port %d...\n' "$PORT" >&2
java csci4311.nc.NetcatUDPServer $PORT <<<$'testdata1\ntestdata2\ntestdata3'
printf 'Send from server complete.\n' >&2

# Test download
printf 'Testing receive from client on port %d...\n' "$((++PORT))" >&2
java csci4311.nc.NetcatUDPServer $PORT
printf 'Receive from client complete.\n' >&2

