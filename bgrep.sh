#!/bin/bash
# -r = recursive
# -i = case-insensitive
# -I = ignore binary files
# -l = prints just the filename
# will open file at first occurence of word

if [ $# -ne 2 ]; then
    echo "Usage: $0 <regex> <dir_name>"
    exit 1
fi

vim -p "+/$1" `grep -riIl "$1" "$2" | uniq`
