#!/bin/bash
# TODO: add support for exec, i.e.:
#       -exec grep -rn interceptTitles {} \;

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dir_name> <file_name>"
    exit 1
fi
vim -p `find "$1" -type f -name "$2"`
