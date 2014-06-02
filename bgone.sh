#!/bin/bash

# Let's set some defaults or define from env vars.
FILTER=${GIT_DEFAULT_FILTER:-"EXTJS*"}
REPO=${GIT_DEFAULT_REPO:-"origin"}

# Swap out for user-provided options if given.
while getopts "f:hlr:" OPTION; do
    case $OPTION in
        f)
            FILTER=$OPTARG
            ;;
        h)
            # Putting quotes around the sentinel (EOF) prevents the text from undergoing parameter expansion.
#            read -d '' HELP << "EOF"
#                Optional flags:
#                -f    The filter to use for existing local branches.
#                      Defaults to 'EXTJS*'
#
#                -l    Will operate in DRY RUN mode.  Will list all branches to be deleted.
#                      This is useful (and safe) when you are not sure which branches will be removed by the filter.
#
#                -r    The name of the remote repository from which to delete the branch.
#                      Defaults to 'origin'
#EOF
#            echo $HELP
#            exit 0
            echo "Optional flags: -f (filter), -l (dry run), -r (remote repo)"
            exit 0
            ;;
        l)
            DRY_RUN=true
            ;;
        r)
            REPO=$OPTARG
            ;;
    esac
done

if [ $DRY_RUN ]; then
    echo "[DRY RUN] The following branches will be removed:"
fi

for BRANCH in `git branch --merged`; do
    # Let's operate on only the desired branches.
    # Append '*' to FILTER for fuzzy matching.
    if [[ "$BRANCH" == $FILTER ]]; then
        if [ $DRY_RUN ]; then
            echo $BRANCH
        else
            echo `git branch -d $BRANCH`
            echo `git push $REPO :$BRANCH`
        fi
    fi
done
