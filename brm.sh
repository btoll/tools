#!/bin/bash
#Example:  ./brm.sh .DS_Store __MACOSX

if [ $# -eq 0 ]; then
    echo "Usage: $0 <FILE OR DIR TO REMOVE> <FILE OR DIR TO REMOVE> etc."
    exit 1
fi

# If more than one cli arg then loop and construct names to find.
if [ $# -gt 1 ]; then
    ARGS="-name $1 "

    # Slice the input, print the args starting from 2.
    for i in ${@:2}
    do
        ARGS+="-o -name $i "
    done

    # Note that $ARGS doesn't need a trailing space in the command below!
    find . \( $ARGS\) -exec rm -rf {} 2&> /dev/null \;
else
    find . \( -name "$1" \) -exec rm -rf {} 2&> /dev/null \;
fi
