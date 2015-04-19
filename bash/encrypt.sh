#!/bin/bash

BINARY=false
CMD="gpg --encrypt -r benjam72@yahoo.com"
SIGN=true

# First, let's make sure that the system on which we are running has the dependencies installed.
if which check_dependencies > /dev/null; then
    check_dependencies -d "gpg" -p "https://www.gnupg.org/"
fi

if [ $? -eq 0 ]; then
    usage() {
        echo "Usage: $0 [args]"
        echo
        echo "Args:"
        echo "--binary, -binary, -b  : Create an encrypted binary file instead of the default ASCII armored one."
        echo "--file, -file, -f      : The name of the new file to encrypt. Can be an absolute or relative path."
        echo "--no-sign              : Don't sign by default."
        echo
    }

    if [ "$#" -eq 0 ]; then
        usage
        exit
    fi

    while [ "$#" -gt 0 ]; do
        OPT="$1"
        case $OPT in
            --binary|-binary|-b) BINARY=true ;;
            --file|-file|-f) shift; FILE=$1 ;;
            --help|-help|-h) usage; exit 0 ;;
            --no-sign) SIGN=false ;;
        esac
        shift
    done

    if [ -z "$FILE" ]; then
        echo "$(tput setaf 1)[ERROR]$(tput sgr0) No file specified."
        exit 1
    fi

    if "$SIGN"; then
        CMD="$CMD --sign"
    fi

    if [ "$BINARY" = "false" ]; then
        CMD="$CMD --armor"
    fi


    # Finally add the file to encipher.
    CMD="$CMD $FILE"

    # Do it!
    $($CMD)

    echo "$(tput setaf 2)[INFO]$(tput sgr0) Task completed."
fi

