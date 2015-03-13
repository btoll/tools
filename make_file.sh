#!/bin/bash

# This assumes that any environment variables will follow the pattern of SDK5, SDK5, SDK6, etc.

CSS_HREF=
DIR=
FILE=
HTML=
JS_SRC=
LOCATION=
TITLE=
FIDDLE=
VERSION=5
BROWSER=
BROWSER_NAME=

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
        echo "--browser, -browser, -b : The browser to use to open this fiddle automatically."
        echo "                          C=Chrome, F=Firefox, S=Safari, O=Opera, V=Vivaldi"
        echo
    }

    if [ "$#" -eq 0 ]; then
        usage
        exit 1
    fi

    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case $OPT in
            --fiddle) shift; FIDDLE=$1 ;;
            --file|-file|-f) shift; FILE=$1 ;;
            --help|-help|-h) usage; exit 0 ;;
            --title|-title|-t) shift; TITLE=$1 ;;
            --version|-version|-v) shift; VERSION=$1 ;;
            --browser|-browser|-b) shift; BROWSER=$1 ;;
        esac
        shift
    done

    if [ -z "$FILE" ]; then
        echo "No file specified, exiting."
        exit 1
    fi

    case "$VERSION" in
        6)
            # TODO
            SDK="$SDK6"
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

    case "$BROWSER" in
        C)
            BROWSER_LOCATION="$CHROME_LOCATION"
            BROWSER_NAME="Chrome"
            ;;

        F)
            BROWSER_LOCATION="$FIREFOX_LOCATION"
            BROWSER_NAME="Firefox"
            ;;
        S)
            BROWSER_LOCATION="$SAFARI_LOCATION"
            BROWSER_NAME="Safari"
            ;;
        O)
            BROWSER_LOCATION="$OPERA_LOCATION"
            BROWSER_NAME="Opera"
            ;;
        V)
            BROWSER_LOCATION="$VIVALDI_LOCATION"
            BROWSER_NAME="Vivaldi"
            ;;
    esac


    # Link to the SDK.
    if [ -z $SDK ]; then
        read -p "Absolute path location of version $VERSION SDK (skip this step by exporting an \$SDK$VERSION env var): " LOCATION
        SDK="$LOCATION"
    fi

    if [ -z "$WEB_SERVER" ]; then
        read -p "Absolute path location of web server (skip this step by exporting a \$WEB_SERVER env var): " LOCATION
        WEB_SERVER="$LOCATION"
    fi


    # Here we're getting the length of the $WEB_SERVER string value (# is the length operator) to use as the offset to get the substring value.
    # We're using it like a bitmask to get at the relative path of the SDK to the web server's public directory. We need to do this to construct
    # the URIs for the test page
    # For example, "/usr/local/www/SDK5" will become "/SDK5" if the $WEB_SERVER value is "/usr/local/www".
    CSS_HREF="http://localhost${SDK:${#WEB_SERVER}}/$DIR/$CSS_HREF"
    JS_SRC="http://localhost${SDK:${#WEB_SERVER}}/$DIR/ext.js"

    HTML="<html>\n<head>\n<title>$TITLE</title>\n<link rel=\"stylesheet\" type=\"text/css\" href=\"$CSS_HREF\" />\n<script type=\"text/javascript\" src=\"$JS_SRC\"></script>\n<script type=\"text/javascript\">\n</script>\n</head>\n\n<body>\n</body>\n</html>"

    echo -e "$HTML" > "$FILE"

    if [ -n "$FIDDLE" ]; then
        get_fiddle "$FIDDLE" "$FILE"
    fi

    echo "File creation successful."

    if [ -n "$BROWSER_LOCATION" ] && [ -n "$LOCAL_FIDDLE_URL" ]; then
        echo "Opening $(basename $FILE) in $BROWSER_NAME"
        /usr/bin/open -a "$BROWSER_LOCATION" "$LOCAL_FIDDLE_URL"$(basename $FILE)

    fi
fi

exit
