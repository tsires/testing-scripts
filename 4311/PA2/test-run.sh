#!/bin/bash
# Test CSCI 4311 PA2
# Run this from root directory of student
# Starting port number, will be automatically incremented for each test
PORT=${1:-'1234'}
# Host, if configurable (here, is static for simplicity's sake)
HOST='localhost'
# Size of the randomly-generated test file for dd
# Common sizes to use are 64K, 512K, and 4M
TESTFILESIZE=${2:-'512K'}
TESTFILE='../TESTFILE.'${TESTFILESIZE}
# Command to use to wait for things to finish:
# "wait" avoids uneccessary waits with properly functioning code
# "sleep n" avoids permanently hanging on faulty code
# Don't set it too short; some code isn't necessarily broken--just inefficient
WAITCMD="sleep 4"
#WAITCMD="wait"

# TODO: use killall in a more restrictive way
# TODO: Allow a group of tests to be killed all at once with ^C and move on to
#       the next group cleanly

# Create TESTFILE if necessary
#[ -e '../TESTFILE.4M' ] || dd if=/dev/urandom of='../TESTFILE.4M' bs=1M count=4
#[ -e '../TESTFILE.512K' ] || dd if=/dev/urandom of='../TESTFILE.512K' bs=1K count=512
#[ -e '../TESTFILE.64K' ] || dd if=/dev/urandom of='../TESTFILE.64K' bs=1K count=64
[ -e "$TESTFILE" ] || dd if=/dev/urandom of="${TESTFILE}" bs="${TESTFILESIZE}" count=1

# Test direct download
printf 'Testing receive from server on port %d... ' "$PORT" >&2
java csci4311.nc.NetcatServer $PORT <"${TESTFILE}" &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT </dev/null >TESTFILE.1 &
$WAITCMD
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test direct upload
printf 'Testing send from client on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT </dev/null >TESTFILE.2 &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT <"${TESTFILE}" &
$WAITCMD
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test proxy download
printf 'Testing receive from server on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT <"${TESTFILE}" &
sleep 0.1
printf 'via proxy on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatProxy $PORT $HOST $((PORT-1)) &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT </dev/null >TESTFILE.3 &
$WAITCMD
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test proxy upload
printf 'Testing send from client on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT </dev/null >TESTFILE.4 &
sleep 0.1
printf 'via proxy on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatProxy $PORT $HOST $((PORT-1)) &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT <"${TESTFILE}" &
$WAITCMD
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test multicast upload
printf 'Testing send from client to servers on... ' >&2
printf 'port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT </dev/null >TESTFILE.5 &
sleep 0.1
printf 'port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT </dev/null >TESTFILE.6 &
sleep 0.1
printf 'port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatServer $PORT </dev/null >TESTFILE.7 &
sleep 0.1
printf 'via multicast proxy on port %d... ' "$((++PORT))" >&2
java csci4311.nc.NetcatMulticast $PORT $HOST $((PORT-3)) $HOST $((PORT-2)) $HOST $((PORT-1)) &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT <"${TESTFILE}" &
$WAITCMD
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Print md5sums of transferred files
printf 'md5sums of transferred files follow\n' >&2
paste <(wc -c "${TESTFILE}") <(md5sum "${TESTFILE}")
for f in TESTFILE.*; do
	paste <(wc -c "$f" | cut -f 1) <(md5sum "$f")
	rm "$f"
done

# Test exec ls
printf 'Testing receive from exec ls on port %d... output follows\n' "$((++PORT))" >&2
java csci4311.nc.NetcatExec $PORT 'ls' &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT </dev/null &
sleep 1
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test exec ls -la
printf 'Testing receive from exec ls -la (multi-word) on port %d... output follows\n' "$((++PORT))" >&2
java csci4311.nc.NetcatExec $PORT 'ls' '-la' &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT </dev/null &
sleep 1
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

# Test exec 'ls -la'
printf 'Testing receive from exec ls -la (single-word) on port %d... output follows\n' "$((++PORT))" >&2
java csci4311.nc.NetcatExec $PORT 'ls -la' &
sleep 0.1
java csci4311.nc.NetcatClient $HOST $PORT </dev/null &
sleep 1
killall java 2>/dev/null && printf 'killed... ' >&2
printf 'done.\n' >&2

