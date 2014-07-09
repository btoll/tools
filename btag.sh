#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <Ext version number>"
    exit 1
fi

# Allow the tag name to be passed as either just the version number or the full tag name.
[[ $1 == extjs* ]] && TAG=$1 || TAG="extjs$1"

git show $TAG | grep commit | awk '{print $2}'
