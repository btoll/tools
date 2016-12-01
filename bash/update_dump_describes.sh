#!/bin/bash

CHANGED=0
SCRIPT_NAME=update_dump_describes
LOCATION=/usr/local/src/git
DEBUG=$(tput setab 7; tput setaf 4)[$SCRIPT_NAME]$(tput sgr0)
ERROR=$(tput setab 1; tput setaf 7)[$SCRIPT_NAME]$(tput sgr0)
INFO=$(tput setab 4; tput setaf 7)[$SCRIPT_NAME]$(tput sgr0)

if [ "$PWD" != $LOCATION ]; then
    $CHANGED=1
    echo "$DEBUG Changing location to $LOCATION..."
    pushd $LOCATION
fi

for file in $(ag -l --json dump_describes); do
    DIR=$(dirname $file)

    pushd "$DIR"

    echo "$DEBUG In repo "$DIR"..."
    echo "$INFO Running npm update dump_describes..."

    npm update dump_describes

    if [ $? -eq 0 ]; then
        echo "$INFO Running npm run specs..."

        npm run specs
    else
        echo "$ERROR dump_describes package could not be updated."
        break
    fi

    if [ $? -eq 0 ]; then
        if [ $(git status | ag _suite | wc -l) -gt 0 ]; then
            echo "$INFO Running git add spec/"$DIR"_suite*..."

            git add spec/"$DIR"_suite*

            if [ $? -eq 0 ]; then
                echo "$INFO Committing and pushing..."

                # GPG sign and don't verify against any pre-commit hooks.
                git commit -Snm 'Updated generated dump_describes suites'
                git push origin master
            fi
        else
            echo "$INFO Nothing to commit."
        fi
    else
        echo -e "$ERROR Specs failed."
        break
    fi

    if [ $? -eq 1 ]; then
        echo "$ERROR Creating the commit and pushing to remote failed."
        break
    fi

    popd
done

if [ $CHANGED -eq 1 ]; then
    popd
fi

echo -e "\n$(tput setaf 2)[SUCCESS]$(tput sgr0) update_dump_describes: All repos were updated and commits pushed (where appropriate)."

