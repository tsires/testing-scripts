testing-scripts
===============

Assorted scripts for testing correctness and functionality of homework submissions for CSCI 4311.  Scripts have become increasingly hackish over time, but the general goal is to provide a somewhat generic (and hopefully, reusable) testing framework in bash.  Design so far is still pretty ad-hoc, and there's little chance of a FIXME ever being fixed after its usefulness has passed (when grading is done).  In their current state, they are most useful for indicating where to look for problems in the source code.


Assignments
-----------

CSCI 4311 PA1: Netcat
- Attempts to transmit and display 3 short lines of text data for manual verification.
- FIXME: Proper testing should involve binary files instead of text.

CSCI 4311 PA2: Advanced Netcat
- Provides core functions for testing in test-common.sh.
- Checks that Java source files are properly packaged (ready to compile).
- Generates a test file containing random (binary) data, with a configurable size.
- Attempts to transmit test file in each mode, then prints md5sums of received files for manual verification.
- Tests functionality of exec mode.  Assignment spec for argument structure was ambiguous, so several interpretations are tried.  Prints output for manual verification.

CSCI 4311 PA3: RESTful Message Server
- Prettified output of core functions for improved readability.
- Provides a suite of functions for making REST requests in test-rest.sh.  This file may be sourced to aid interactive testing.
- Assignment spec included errors in expected JSON syntax, so a function is provided to (mostly) translate these into valid JSON.
- Provides several functions to check that some property holds true for the status code or body of a REST response (<rest command> | expect_*).
- TODO: Refactor to store response body and status code, then run multiple checks against this data.
- TODO: Automatically start and stop the server to provide a clean state for each test case, to avoid propagating errors into later tests.


Basic functions
---------------

* Print a formatted message to introduce a test.
```bash
check "Descriptive message"
```

* Mark test as passed.
  Returns 0 to indicate success.
```bash
pass
```

* Mark test as failed, with an optional message.  Prints out one line for each parameter passed in.
  Multi-line messages may be ideal for printing out lists of things, with one per line.
  Returns 1 to indicate error.
```bash
fail
fail "Short reason for failure"
fail "Reason #"{1..10}
```

* Skip a test without printing any outcome.
  Returns 0.
```bash
skip
```

* Perform a simple check, potentially with some parameters.
  If this check fails, the last thing this function should do is call "fail".
```bash
check_*
```

* Perform some check against data piped in to stdin, potentially with some parameters.
  If this check fails, this function should return 1.
  These are usually simple conditional expressions.
```bash
expect_*
```


Building test cases
-------------------

* Compound test, where each "check_*" will call "fail" on individual failure.
```bash
check "Descriptive message" && check_* && check_* && check_* && pass
```

* Piped test structure, where "some_command" generates some output and "expect_*" will return an error code on failure.
  TODO: Failure behavior here should probably be made more consistent with typical check_* behavior, or vice versa.
```bash
check "Descriptive message" && some_command | expect_* && pass || fail
```

* Simply print a formatted message and move on.
```bash
check "Descriptive message" && skip
```


Return codes
------------

For even more automated processing that simply gives an indication of success or failure, you may want to silence all output and discontinue tests following any failure condition.  Success or failure will be indicated by the return code of the entire test script.
```bash
bash -o errexit test-script.sh 2>/dev/null
```
