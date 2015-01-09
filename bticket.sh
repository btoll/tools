#!/bin/bash

VER=$2
EXPECTED_ARGS=2
# Note no trailing forward slashes for the dir locations.
DEFAULT_SDK_LOCATION="../../.."
DEFAULT_BUILDS_LOCATION="../../builds"
DEBUG_SCRIPT="ext.js"
ONREADY="Ext.onReady(function () {\n});"

# First establish some conditions that must be met or exit early.
if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Usage: $0 <ticket_dir_name> <ext_version>"
    exit 1
else
    if [ -d $1 ]; then
        echo "Warning: Directory already exists, exiting..."
        exit 1
    fi
fi

# This assumes that your git repos are SDK4, SDK5, etc.
# If $VER contains the string "SDK", then get the 4th char which will be the major version number.
# https://stackoverflow.com/questions/229551/string-contains-in-bash
if [[ $VER == *SDK* ]]; then
    MAJOR_VER=${VER:3}

    if [ $MAJOR_VER -lt 5 ]; then
        DIR="extjs"
        CSS_HREF="${EXT_SDK:-$DEFAULT_SDK_LOCATION}/$VER/$DIR/resources/css/ext-all.css"
    else
        DIR="ext"
        CSS_HREF="${EXT_SDK:-$DEFAULT_SDK_LOCATION}/$VER/ext/packages/ext-theme-classic/build/resources/ext-theme-classic-all.css"
    fi

    # Link to the SDK.
    if [ -z $EXT_SDK ]; then
        # Get preset environment variable or set a default location (logical OR ----> ":-").
        read -p "Location of SDK: [$DEFAULT_SDK_LOCATION] " SDK
        # If user accepted default location then SDK var will be unset.
        SDK=${SDK:-$DEFAULT_SDK_LOCATION}
    else
        SDK="$EXT_SDK/$VER"
    fi

    JS_SRC="$SDK/$DIR/$DEBUG_SCRIPT"
else
    # Extract the first character of the Ext version.
    MAJOR_VER=${VER:0:1}

    # Link to the SDK.
    # If the env var hasn't been set for the EXT_BUILDS, then prompt for its location.
    if [ -z $EXT_BUILDS ]; then
        # Get preset environment variable or set a default location (logical OR ----> ":-").
        read -p "Location of build: [$DEFAULT_BUILDS_LOCATION] " SDK
        # If user accepted default location then SDK var will be unset.
        SDK="${SDK:-$DEFAULT_BUILDS_LOCATION}/$VER"
    else
        SDK="$EXT_BUILDS/$VER"
    fi

    # If the version number is 2.x or 3.x then change the debug script.
    if [ $MAJOR_VER -eq 4 ]; then
        DEBUG_SCRIPT="ext-debug.js"
    elif [ $MAJOR_VER -lt 4 ]; then
        DEBUG_SCRIPT="ext-all-debug.js"
        ADAPTER="<script type=\"text/javascript\" src=\"$SDK/adapter/ext/ext-base.js\"></script>\n"
    fi

    if [ $MAJOR_VER -lt 5 ]; then
        CSS_HREF="$SDK/resources/css/ext-all.css"
    else
        CSS_HREF="$SDK/packages/ext-theme-classic/build/resources/ext-theme-classic-all.css"
    fi

    JS_SRC=$SDK/$DEBUG_SCRIPT
fi

# Create the new ticket dir.
mkdir -m 0755 -p $1

HTML="<html>\n<head>\n<title>$1</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"$CSS_HREF\" />\n$ADAPTER<script type=\"text/javascript\" src=\"$JS_SRC\"></script>\n<script type=\"text/javascript\">\n$ONREADY\n</script>\n</head>\n\n<body>\n</body>\n</html>"

# Echo HTML honoring the new lines (-e flag).
echo -e $HTML > $1/index.html

# Uncomment the statement below if you have multiple SDK locations.
#echo ""
echo "Created new ticket in directory $1."
echo "Linked to src location at $SDK"
exit 0
