#!/bin/bash

# This assumes that any environment variables will follow the pattern of SDK5, SDK5, SDK6, etc.

CSS_HREF=
DIR=
DOMAIN="http://localhost"
FIDDLE=
FILE=
HTML=
JS_SRC=
LOCATION=
TITLE=
URL=
VERSION=5

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "get_fiddle" -p "https://github.com/btoll/utils/blob/master/get_fiddle.sh"
fi

if [ $? -eq 0 ]; then
    usage() {
        echo "make_file"
        echo
        echo "Usage: $0 [args]"
        echo
        echo "Args:"
        echo "--fiddle                : The url of the Fiddle to whose JavaScript will be inserted into the new file."
        echo
        echo "--file, -file, -f       : The name of the new file to create. Can be an absolute or relative path."
        echo
        echo "--title, -title, -t     : The value of the HTML <title> node."
        echo
        echo "--version, -version, -v : The version of Ext."
        echo "                          Defaults to most current major release."
        echo
    }

    if [ "$#" -eq 0 ]; then
        usage
        exit
    fi

    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case $OPT in
            --fiddle) shift; FIDDLE=$1 ;;
            --file|-file|-f) shift; FILE=$1 ;;
            --help|-help|-h) usage; exit 0 ;;
            --title|-title|-t) shift; TITLE=$1 ;;
            --version|-version|-v) shift; VERSION=$1 ;;
        esac
        shift
    done

    if [ -z "$FILE" ]; then
        echo "$(tput setaf 1)[ERROR]$(tput sgr0) No file specified."
        exit 1
    fi

    case "$VERSION" in
        6)
            SDK="$SDK6"
            DIR="ext"
            CSS_HREF="build/classic/theme-classic/resources/theme-classic-all-debug.css"
            ;;

        5)
            SDK="$SDK5"
            DIR="ext"
            CSS_HREF="packages/ext-theme-neptune/build/resources/ext-theme-neptune-all.css"
            ;;

        4)
            SDK="$SDK4"
            DIR="extjs"
            CSS_HREF="resources/css/ext-all.css"
            ;;
    esac

    # Link to the SDK.
    if [ -z "$SDK" ]; then
        read -p "Absolute path location of version $VERSION SDK (skip this step by exporting an \$SDK$VERSION env var): " LOCATION
        SDK="$LOCATION"
    fi

    if [ -z "$WEBSERVER" ]; then
        read -p "Absolute path location of web server (skip this step by exporting a \$WEBSERVER env var): " LOCATION
        WEBSERVER="$LOCATION"
    fi

    # Here we're getting the length of the $WEBSERVER string value (# is the length operator) to use as the
    # offset to get the substring value. We're using it like a bitmask to get at the relative path of the SDK
    # to the web server's public directory. We need to do this to construct the URIs for the test page For
    # example, "/usr/local/www/SDK5" will become "/SDK5" if the $WEBSERVER value is "/usr/local/www".
    #
    # Chop off last char it it's a trailing slash.
    if [[ "$WEBSERVER" == */ ]]; then
        WEBSERVER=${WEBSERVER%?}
    fi

    # Chop off last char it it's a trailing slash.
    if [[ "$SDK" == */ ]]; then
        SDK=${SDK%?}
    fi

    URL="$DOMAIN${SDK:${#WEBSERVER}}/$DIR"
    CSS_HREF="$URL/$CSS_HREF"
    JS_SRC="$URL/ext.js"

    HTML="<html>\n<head>\n<title>$TITLE</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"$CSS_HREF\" />\n<script type=\"text/javascript\" src=\"$JS_SRC\"></script>\n<script type=\"text/javascript\">\n</script>\n</head>\n\n<body>\n</body>\n</html>\n"

    echo -e "$HTML" > "$FILE"

    if [ -n "$FIDDLE" ]; then
        get_fiddle "$FIDDLE" "$FILE"
    fi

    # Only proceed if the Fiddle was downloaded successfully.
    if [ $? -eq 0 ]; then
        echo "$(tput setaf 2)[INFO]$(tput sgr0) File creation successful."
        open "$DOMAIN${PWD:${#WEBSERVER}}/$FILE"
    fi
fi

exit

