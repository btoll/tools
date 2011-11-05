#!/bin/bash
# -r = recursive
# -i = case-insensitive
# -I = ignore binary files
# will open file at first occurence of word

if [ $# -ne 2 ]; then
    echo "Usage: $0 <regex> <dir_name>"
    exit 1
fi

vim -O "+/$1" `grep -riI "$1" "$2" | cut -d : -f 1 | uniq`
