#!/bin/bash
# Get up and running quickly with the test case and the versioned files that make up the bug ticket.
# If not given a bug ticket as an argument, `bootstrap` will assume the current topic branch.

# Note the dependencies on the `git-get-hash` alias and the `git-ls` extension:
# https://github.com/btoll/utils/tree/master/git

FILES=
SHA=
TESTCASE=
TICKET=$1

# http://stackoverflow.com/a/14127035/125349
if [ $PWD != $(git rev-parse --show-toplevel) ]; then
    echo "You need to run this command from the toplevel of the working tree."
else
    if [ -z "$TICKET" ]; then
        TICKET=$(git rev-parse --abbrev-ref HEAD)
    fi

    SHA=$(git get-hash "$TICKET")
    TESTCASE="$BUGS$TICKET/index.html"

    if [ -f "$TESTCASE" ]; then
        FILES="$TESTCASE"
    fi

    # We need a space here to separate the test case from the files returned by git-ls.
    FILES+=" "$(git ls --commit "$SHA")

    vim -p $FILES
fi

