#!/bin/bash

# Note this needs to be global so all functions can access it.
FIDDLE_TIMESTAMP=

fiddle-cleanup() {
    rm /tmp/"$FIDDLE_TIMESTAMP"
    #unset $FIDDLE_TIMESTAMP
    FIDDLE_TIMESTAMP=
}

fiddle-download() {
    if [ "$#" -eq 0 ]; then
        echo "You must provide a url."
        exit 1
    fi

    # Use the Unix timestamp as the name of the temp file to avoid any name collisions.
    FIDDLE_TIMESTAMP=$(date +%s)
    local BASENAME=
    local FIDDLE="$1"
    local SED_RANGE_BEGIN="<script type=\"text\/javascript\">"
    local SED_RANGE_END="<\/script>"

    # Let's re-use $FIDDLE.
    BASENAME=$(basename $FIDDLE)

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
    # There's probably a better way to do this than creating a temporary file.
    #

    # Download to a dir where we know we'll have write permissions.
    curl $FIDDLE | gsed -n "/$SED_RANGE_BEGIN/,/$SED_RANGE_END/{/$SED_RANGE_BEGIN/{d;p;n};/$SED_RANGE_END/{q};p}" > /tmp/$FIDDLE_TIMESTAMP
}

fiddle-read() {
    sed -i '' -e "/<script type=\"text\/javascript\">/ {
        r /tmp/$FIDDLE_TIMESTAMP
    }" index.html
}

