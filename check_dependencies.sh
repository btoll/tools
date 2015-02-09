#!/bin/bash

DEPENDENCIES=
DEPENDENCY=
FAILED_DEPENDENCIES=
PACKAGES=
D=
P=

while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        --dependencies|-dependencies|-d) shift; D=$1 ;;
        --help|-help|-h) usage; exit 0 ;;
        --packages|-packages|-p) shift; P=$1 ;;
    esac
    shift
done

# Read words into an array.
IFS=";" read -a DEPENDENCIES <<< "$D"
IFS=";" read -a PACKAGES <<< "$P"

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

