#!/bin/bash

FILE="index.html"
TICKET="$1"
VERSION=$2

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
make_file "$FILE" "$VERSION" "$TICKET"

echo "Created new ticket in directory $TICKET."
echo "Resources are pointing to $VERSION"
exit 0

