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
IFS=";" read -ra DEPENDENCIES <<< "$D"
IFS=";" read -ra PACKAGES <<< "$P"

for n in ${!DEPENDENCIES[*]}; do
    DEPENDENCY=${DEPENDENCIES[n]}

    which "$DEPENDENCY" > /dev/null || {
        FAILED_DEPENDENCIES+="\n$(tput smul)Name:$(tput sgr0) $DEPENDENCY\n$(tput smul)Package:$(tput sgr0) ${PACKAGES[n]}\n"
    }
done

if [ -n "$FAILED_DEPENDENCIES" ]; then
    echo -e "\n$(tput setaf 3)[WARNING]$(tput sgr0) This script has dependencies that are not present on your system."
    echo "Please install the following:"
    echo -e "$FAILED_DEPENDENCIES"
    touch /tmp/failed_dependencies
    exit 1
fi

exit 0

