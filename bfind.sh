#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dir_name> <file_name>"
    exit 1
fi
vim -O `find "$1" -name "$2"`
