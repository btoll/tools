#!/bin/bash
# Note that when given a TARGET that we musn't ever mutate it.
# No matter whether we're given a TARGET or not, we need to determine the ABS_PATH. This is used by sed to know how to locate the TARGET.
# The first part of this script is all about determining the ABS_PATH.

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 FIDDLE [ TARGET ]"
    exit 1
fi

FIDDLE="$1"
# If exists, the TARGET could be an absolute or relative path.
TARGET="$2"
BASENAME=$(basename $FIDDLE)
SED_RANGE_BEGIN="<script type=\"text\/javascript\">"
SED_RANGE_END="<\/script>"

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "gsed;make_file" -p "\"To install on Mac, do 'brew install coreutils'\";https://github.com/btoll/utils/blob/master/make_file.sh"
fi

create_file() {
    if which make_file > /dev/null; then
        set_abs_path
        make_file -f "$TARGET" -v SDK5
    else
        echo "Error: $TARGET target file does not exist."
        exit 1
    fi
}

# Because the script could be given a filename and a location anywhere on the filesystem (or one that we should create
# anywhere on the filesystem, the only thing we need to determine is whether the target file is in the CWD.
set_abs_path() {
    # sed needs to know where the target file is on the filesystem.
    ABS_PATH=$([ $(dirname "$TARGET") == '.' ] && echo "$PWD/$TARGET" || echo "$TARGET")
}

# When give a target, we need to know if it exists. If so, just determine WHERE it is. If not, create it.
if [ -n "$TARGET" ]; then
    if [ ! -f "$TARGET" ]; then
        # Note that we don't want to waste cycles determining the ABS_PATH if `make_file` isn't on the system!
        create_file
    else
        set_abs_path
    fi
else
    # Use a path if given, if not default to the fiddle basename (NOT index.html, don't want to blow it away if it exists :).
    TARGET="$BASENAME.html"
    create_file
fi

# Let's accept either a regular Fiddle URL or a Fiddle preview URL.
if [ "$BASENAME" != "preview" ]; then
    # Rename in this form: https://fiddle.sencha.com/fiddle/da1/preview
    FIDDLE="https://fiddle.sencha.com/fiddle/$BASENAME/preview"
fi

# Then download and extract just what we need.
#
# Here we will extract every line after the launch method and before the closing <script> tag.
# -n                            -> don't print
# '/<script...>/, /<\/script>/  -> match range
# {                             -> if in this range
#     /<script...>/             -> and line matches /<script...>/
#         {d;p;n};              -> do not print the first line (the match), print the next line and read next row
#     /<\/script>/              -> if line matches "<\/script>"
#         q;                    -> quit, we have done all printing
#     p                         -> if we come to here, print the line
# }
#
# http://stackoverflow.com/a/744093
# Perhaps a better way to do this than creating a temporary file?
#
if [ ! -f "/tmp/$BASENAME" ]; then
    # Download to a dir where we know we'll have write permissions.
    curl $FIDDLE | gsed -n "/$SED_RANGE_BEGIN/,/$SED_RANGE_END/{/$SED_RANGE_BEGIN/{d;p;n};/$SED_RANGE_END/{q};p}" > /tmp/"$BASENAME"

    # Check to make sure it downloaded correctly.
    read SIZE _ <<<$(du /tmp/"$BASENAME")
    if [[ "$SIZE" -eq 0 ]]; then
        echo -e "\nThere was a problem with the download! Chances are you are trying to download a Fiddle with a premium build.\n"

        read -p "Delete temp file? [Y/n] " CONTINUE
        if [ "$CONTINUE" != "n" ]; then
            rm /tmp/"$BASENAME"
        fi

        exit 1
    fi
fi

sed -i '' -e "/$SED_RANGE_BEGIN/ {
    r /tmp/$BASENAME
}" "$ABS_PATH"

