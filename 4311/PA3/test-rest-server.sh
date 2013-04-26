#!/bin/bash
# Test functionality of CSCI 4311 PA3
# Set the environment vars $TEST_HOST and $TEST_PORT to specify where the
#   server is listening, or pass them in as parameters (Default: localhost:1234)

TEST_HOST=${1:-${TEST_HOST:-localhost}}
TEST_PORT=${2:-${TEST_PORT:-1234}}

# Include common functions
source "$(dirname "$0")/test-common.sh"
# Include rest functions
source "$(dirname "$0")/test-rest.sh"

check 'Check that no users exist' && user_index | fix_json | expect_empty && pass || fail
check 'Check that no topics exist' && topic_index | fix_json | expect_empty && pass || fail

check ':: Create and index users' && skip
check 'Create user "test"' && user_create 'test' 'TestUser' | fix_json | expect_empty && pass || fail
check 'Index users' && user_index | fix_json | expect_key_value '0' 'test' && pass || fail
check 'Create user "test2"' && user_create 'test2' 'TestUserB' | fix_json | expect_empty && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '2' && pass || fail
check 'Create duplicate user "test2"' && user_create 'test' 'TestUserC' | expect_error '405' && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '2' && pass || fail
check 'Create user "test3" (with spaces)' && user_create 'test3' 'Test User C' | fix_json | expect_empty && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '3' && pass || fail

check ':: Show users' && skip
check 'Show user "test"' && user_show 'test' | fix_json | expect_key_value 'id' 'test'  && pass || fail
check 'Show user "test2"' && user_show 'test2' | fix_json | expect_key_value 'name' 'TestUserB'  && pass || fail
check 'Show user "test3" (with spaces)' && user_show 'test3' | fix_json | expect_key_value 'name' 'Test User C' && pass || fail
check 'Show user "nonexistent"' && user_show 'nonexistent' | expect_error '404'  && pass || fail

check ':: Delete users' && skip
check 'Delete user "test"' && user_delete 'test' | fix_json | expect_empty && pass || fail
check 'Show user "test"' && user_show 'test' | expect_error '404'  && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '2' && pass || fail
check 'Delete user "test2"' && user_delete 'test2' | fix_json | expect_empty && pass || fail
check 'Show user "test2"' && user_show 'test2' | expect_error '404'  && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '1' && pass || fail
check 'Delete user "test3"' && user_delete 'test3' | fix_json | expect_empty && pass || fail
check 'Show user "test3"' && user_show 'test3' | expect_error '404'  && pass || fail
check 'Delete user "test3" again' && user_delete 'test3' | expect_error '404' && pass || fail
check 'Delete user "nonexistent"' && user_delete 'nonexistent' | expect_error '404' && pass || fail
check 'Index users' && user_index | fix_json | expect_empty && pass || fail 'Failed to show empty user list'

check ':: Re-create users' && skip
check 'Create user "test"' && user_create 'test' 'TestUser' | fix_json | expect_empty && pass || fail
check 'Create user "test2"' && user_create 'test2' 'TestUserB' | fix_json | expect_empty && pass || fail
check 'Index users' && user_index | fix_json | expect_array_length '2' && pass || fail

check ':: Post messages' && skip
check 'Create message as "test" about "#topic"' && message_create 'test' 'Hello, #topic' | fix_json | expect_empty && pass || fail
check 'Index topics' && topic_index | fix_json | expect_key_value '0' 'topic' && pass || fail
check 'Show topic "#topic"' && topic_show 'topic' | fix_json | expect_key_value '0' 'id' 'test' && pass || fail
check 'Create message as "test2" about "#hello" and "#topic"' && message_create 'test2' '#Hello again, #topic' | fix_json | expect_empty && pass || fail
check 'Index topics' && topic_index | fix_json | expect_array_length '2' && pass || fail
check 'Show topic "#hello"' && topic_show 'hello' | fix_json | expect_key_value '0' 'message' '#Hello again, #topic' && pass || fail
check 'Create message as "nonexistent"' && message_create 'nonexistent' 'Hello, #topic' | expect_error '405' && pass || fail
check 'Show topic "#topic"' && topic_show 'topic' | fix_json | expect_array_length '2' && pass || fail
check 'Create message as "test" about "#topic" (with punctuation)' && message_create 'test' 'Goodbye, #topic!' | fix_json | expect_empty && pass || fail
check 'Index topics' && topic_index | fix_json | expect_array_length '2' && pass || fail 'Message parsing does not properly match id_strings'
check 'Delete topic "#topic!" (in case it was wrongly created)' && topic_delete 'topic!' | fix_json | expect_empty && pass || fail
check 'Show topic "#nonexistent"' && topic_show 'nonexistent' | fix_json | expect_empty && pass || fail
check 'Create message as "test" about "#hello" and "#topic"' && message_create 'test' '#Hello again, #topic' | fix_json | expect_empty && pass || fail

check ':: Delete users (to check that posts are deleted)' && skip
check 'Show topic "#hello"' && topic_show 'hello' | fix_json | expect_array_length '2' && pass || fail
check 'Delete user "test2"' && user_delete 'test2' | fix_json | expect_empty && pass || fail
check 'Show topic "#hello"' && topic_show 'hello' | fix_json | expect_array_length '1' && pass || fail

check ':: Delete topics (to check that posts are deleted)' && skip
check 'Delete topic "#topic"' && topic_delete 'topic' | fix_json | expect_empty && pass || fail
check 'Show topic "#topic"' && topic_show 'topic' | fix_json | expect_empty && pass || fail
check 'Delete topic "#topic" again' && topic_delete 'topic' | fix_json | expect_empty && pass || fail
check 'Delete topic "#nonexistent"' && topic_delete 'nonexistent' | fix_json | expect_empty && pass || fail
check 'Show topic "#hello"' && topic_show 'topic' | fix_json | expect_array_length '1' && pass || fail 'Messages with multiple topics are duplicated'

