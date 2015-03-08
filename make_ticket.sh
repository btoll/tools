#!/bin/bash

FILE="index.html"
TICKET="$1"
VERSION=$2

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "make_file;get_fiddle" -p "https://github.com/btoll/utils/blob/master/make_file.sh;https://github.com/btoll/utils/blob/master/get_fiddle.sh"
fi

# First establish some conditions that must be met or exit early.
if [ $# -ne 2 ]; then
    echo "Usage: $0 TICKET VERSION"
    exit 1
else
    if [ -d $1 ]; then
        echo "Warning: Directory already exists, exiting..."
        exit 1
    fi
fi

# Create the new ticket directory...
mkdir -m 0755 -p "$TICKET" && cd "$TICKET"
# ...make the document.
make_file -f "$FILE" -v "$VERSION" -t "$TICKET"

echo "Created new ticket in directory $TICKET."
echo "Resources are pointing to $VERSION"

