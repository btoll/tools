#!/bin/bash

# This assumes that your git repos are SDK5, SDK5, etc.
# If $VERSION contains the string "SDK", then get the 4th char which will be the major version number.
# https://stackoverflow.com/questions/229551/string-contains-in-bash
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 FILE VERSION [ OPTIONS ]"
    exit 1
fi

ADAPTER=
CSS_HREF=
DEBUG_SCRIPT="ext.js"
# Note no trailing forward slashes for the dir locations.
DEFAULT_SDK_LOCATION="../../.."
DEFAULT_BUILDS_LOCATION="../../builds"
DIR=
FILE="$1"
HTML=
JS_SRC=
MAJOR_VERSION=
# Note that scripts can call this and add extra args. Assume if there is a third funarg that it's a ticket (i.e., called from make_ticket).
TITLE=${3:-$FILE}
VERSION="$2"

if [[ $VERSION == *SDK* ]]; then
    # Extract the last character of the SDK version.
    MAJOR_VERSION=${VERSION:3}

    if [ $MAJOR_VERSION -lt 5 ]; then
        DIR="extjs"
        CSS_HREF="${EXT_SDK:-$DEFAULT_SDK_LOCATION}/$VERSION/$DIR/resources/css/ext-all.css"
    else
        DIR="ext"
        CSS_HREF="${EXT_SDK:-$DEFAULT_SDK_LOCATION}/$VERSION/ext/packages/ext-theme-crisp/build/resources/ext-theme-crisp-all.css"
    fi

    # Link to the SDK.
    if [ -z $EXT_SDK ]; then
        # Get preset environment variable or set a default location (logical OR ----> ":-").
        read -p "Location of SDK: [$DEFAULT_SDK_LOCATION] " SDK
        # If user accepted default location then SDK var will be unset.
        SDK=${SDK:-$DEFAULT_SDK_LOCATION}
    else
        SDK="$EXT_SDK/$VERSION"
    fi

    JS_SRC="$SDK/$DIR/$DEBUG_SCRIPT"
else
    # Extract the first character of the Ext version.
    MAJOR_VERSION=${VERSION:0:1}

    # Link to the SDK.
    # If the env var hasn't been set for the EXT_BUILDS, then prompt for its location.
    if [ -z $EXT_BUILDS ]; then
        # Get preset environment variable or set a default location (logical OR ----> ":-").
        read -p "Location of build: [$DEFAULT_BUILDS_LOCATION] " SDK
        # If user accepted default location then SDK var will be unset.
        SDK="${SDK:-$DEFAULT_BUILDS_LOCATION}/$VERSION"
    else
        SDK="$EXT_BUILDS/$VERSION"
    fi

    # If the version number is 2.x or 3.x then change the debug script.
    if [ $MAJOR_VERSION -eq 4 ]; then
        DEBUG_SCRIPT="ext-debug.js"
    elif [ $MAJOR_VERSION -lt 4 ]; then
        DEBUG_SCRIPT="ext-all-debug.js"
        ADAPTER="<script type=\"text/javascript\" src=\"$SDK/adapter/ext/ext-base.js\"></script>\n"
    fi

    if [ $MAJOR_VERSION -lt 5 ]; then
        CSS_HREF="$SDK/resources/css/ext-all.css"
    else
        CSS_HREF="$SDK/packages/ext-theme-crisp/build/resources/ext-theme-crisp-all.css"
    fi

    JS_SRC=$SDK/$DEBUG_SCRIPT
fi

HTML="<html>\n<head>\n<title>$TITLE</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"$CSS_HREF\" />\n$ADAPTER<script type=\"text/javascript\" src=\"$JS_SRC\"></script>\n<script type=\"text/javascript\">\n</script>\n</head>\n\n<body>\n</body>\n</html>"

# Echo HTML honoring the new lines (-e flag).
echo -e "$HTML" > "$PWD/$FILE"
exit 0

