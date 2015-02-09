#!/bin/bash

DEPENDENCIES=
DEPENDENCY=
FAILED_DEPENDENCIES=
FILE="index.html"
TICKET="$1"
VERSION=$2

DEPENDENCIES=(make_file)
PACKAGES=(
    "https://github.com/btoll/utils/blob/master/make_file.sh"
)

for n in ${!DEPENDENCIES[*]}; do
    DEPENDENCY=${DEPENDENCIES[n]}

    which $DEPENDENCY > /dev/null || {
        FAILED_DEPENDENCIES+="\nName: $DEPENDENCY\nPackage: ${PACKAGES[n]}\n"
    }
done

if [ -n "$FAILED_DEPENDENCIES" ]; then
    echo "This script has several dependencies that are not present on your system."
    echo "Please install the following:"
    echo -e $FAILED_DEPENDENCIES
    exit 1
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
exit 0

