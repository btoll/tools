#!/bin/bash

PATTERN="^\s*debugger"
#    PATTERN="$1"
PREPEND="$(tput setaf 6)[INFO]$(tput sgr0)"
FILES=$(ag -l --vimgrep "$PATTERN")

if [ -n "$FILES" ]; then
    echo "---------"
    echo "$(tput setaf 1)[WARNING]$(tput sgr0) This utility modifies the files in-place, so know what you are doing!"
    echo "---------"

    for FILE in $FILES; do
        read -p "Pattern found in $(tput setaf 3)$FILE$(tput sgr0)... Choose [$(tput setaf 2)R$(tput sgr0)emove line/$(tput setaf 2)C$(tput sgr0)omment out/$(tput setaf 2)S$(tput sgr0)kip]? " ACTION

        if [ "$ACTION" == "R" ] || [ "$ACTION" == "r" ]; then
            gsed -i "/$PATTERN/d" "$FILE"
            echo "$PREPEND Removed the line matching the pattern $PATTERN in $FILE."
        elif [ "$ACTION" == "C" ] || [ "$ACTION" == "c" ]; then
            gsed -i 's_\('"$PATTERN"'\)_//\1_' "$FILE"
            echo "$PREPEND Commented out the text matching the pattern $PATTERN in $FILE."
        else
            echo "$PREPEND Skipped $FILE."
        fi
    done
fi

