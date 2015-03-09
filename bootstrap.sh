#!/bin/bash
# Get up and running quickly with the test case and the versioned files that make up the bug ticket.
# If not given a bug ticket as an argument, `bootstrap` will assume the current topic branch.

# Note the dependencies on the `git-get-hash` alias and the `git-ls` extension:
# https://github.com/btoll/utils/tree/master/git

# TODO fix errors when non-existent branch

BRANCH=
DIR=
FILE=
FILES=
SHA=
SHORT_FORM=
TESTCASE=
TICKET=

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "git-ls" -p "https://github.com/btoll/utils/blob/master/git/bin/git-ls"

    if [ -f /tmp/failed_dependencies ]; then
        rm /tmp/failed_dependencies
        exit 1
    fi
fi

usage() {
    echo "bootstrap"
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "--branch, -branch, -b   : If the branch name is different from the ticket name, specify the branch name"
    echo "                          using this flag."
    echo
    echo "--ticket, -ticket, -t   : The bug ticket number."
    echo
    echo "Note if no arguments are passed, the current branch name will be assumed as the name of the ticket."
}

# http://stackoverflow.com/a/14127035/125349
if [ $PWD != $(git rev-parse --show-toplevel) ]; then
    echo "You need to run this command from the toplevel of the working tree."
    exit 1
fi

if [ -z "$BUGS" ]; then
    read -p "Location of bugs directory (set a \$BUGS env var to skip this step): " LOCATION

    if [ -n "$LOCATION" ]; then
        BUGS="$LOCATION"
    else
        echo "No location given, exiting."
        exit 1
    fi
fi

# Allow `bootstrap` to be called w/o any args, will assume the current topic branch name as the ticket.
if [ "$#" -eq 0 ]; then
    SHORT_FORM=true
else
    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case $OPT in
            --branch|-branch|-b) shift; BRANCH=$1 ;;
            --help|-help|-h) usage; exit 0 ;;
            --ticket|-ticket|-t) shift; TICKET=$1 ;;
        esac
        shift
    done

    # Note that if the long form of the command is used that $TICKET must be specified.
    if [ -z "$TICKET" ]; then
        echo "Error: No ticket specified."
        exit 1
    fi
fi

# If no branch, let's assume the current one.
if [ "$SHORT_FORM" ] || [ -z "$BRANCH" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # If using the short form, there will be no $TICKET, make it the same as $BRANCH.
    TICKET=${TICKET:-"$BRANCH"}
fi

# If the bug directory exists, get every html file in it (they should all be test cases).
DIR="$BUGS/$TICKET"
if [ -d "$DIR" ]; then
    for FILE in "$DIR"/*.html; do
        # We need a space here to separate the files.
        FILES+=" $FILE"
    done
fi

SHA=$(git get-hash "$BRANCH")

# We need a space here to separate the test case from the files returned by git-ls.
FILES+=" "$(git ls --commit "$SHA")

vim -p $FILES

