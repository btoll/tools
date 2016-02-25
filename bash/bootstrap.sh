#!/bin/bash
# Get up and running quickly with the versioned files that make up the last commit.
# If not given any arguments, `bootstrap` will assume the current topic branch.

# Note the dependencies on the `git-ls` extension:
# https://github.com/btoll/git/blob/master/bin/git-ls

# TODO fix errors when non-existent branch
BRANCH=
FILES=
SHA=

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "git-ls" -p "https://github.com/btoll/git/blob/master/bin/git-ls"
fi

if [ $? -eq 0 ]; then
    usage() {
        echo "bootstrap"
        echo
        echo "Usage: $0 [args]"
        echo
        echo "Args:"
        echo "--branch, -b   : If the branch name is different from the ticket name, specify the branch name"
        echo "                 using this flag."
        echo
        echo "Note if no arguments are passed, the current branch name will be assumed as the name of the ticket."
    }

    # http://stackoverflow.com/a/14127035/125349
    if [ $PWD != $(git rev-parse --show-toplevel) ]; then
        echo "$(tput setaf 3)[WARNING]$(tput sgr0) You need to run this command from the toplevel of the working tree."
        exit 1
    fi

    # Allow `bootstrap` to be called w/o any args, will assume the current topic branch.

    if [ "$#" -gt 0 ]; then
        while [ "$#" -gt 0 ]; do
            OPT="$1"
            case $OPT in
                --branch|-b) shift; BRANCH=$1 ;;
                --help|-h) usage; exit 0 ;;
            esac
            shift
        done
    fi

    # If no branch, let's assume the current one.
    if [ -z "$BRANCH" ]; then
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
    fi

    SHA=$(git rev-parse "$BRANCH")

    # We need a space here to separate the test case from the files returned by git-ls.
    FILES+=" "$(git ls --commit "$SHA")

    vim $FILES
fi

exit

