#!/bin/bash

BRANCH=true
FIDDLE=
SDK=
TICKET=
VERSION=

usage() {
    echo "bsession"
    echo
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo " -help, -h              : Help"
    echo
    echo "--fiddle, -fiddle, -f   : Location of Fiddle to download using curl and paste into index.html in new bug dir."
    echo
    echo "--no-branch             : Don't create a new git topic branch (by default it will)."
    echo
    echo "--ticket, -ticket, -t   : The bug ticket number."
    echo
    echo "--version, -version, -v : The framework major version. Defaults to 5."
    echo
}

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

# Swap out for user-provided options if given.
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        -help|-h) usage; exit 0 ;;
        --fiddle|-fiddle|-f) shift; FIDDLE=$1 ;;
        --no-branch) BRANCH=false ;;
        --ticket|-ticket|-t) shift; TICKET=$1 ;;
        --version|-version|-v) shift; VERSION=$1 ;;
    esac
    shift
done

SDK=SDK${VERSION:-5}

# If $FIDDLE is set, then let's go through the process of creating the bug dir,
# downloading the Fiddle preview, extracting our best-guess-attempt at the code
# body and finally slapping that into the new index.html.
if [ -n "$FIDDLE" ]; then
    # Let's re-use and re-define $FIDDLE.
    #
    # First, rename in this form: https://fiddle.sencha.com/fiddle/da1/preview
    FIDDLE="https://fiddle.sencha.com/fiddle/"$(basename $FIDDLE)"/preview"
    # Then download and extract just what we need.
    FIDDLE=$(curl $FIDDLE | sed -e '1,/launch/d' -e '/<\/script>/,$d')

    pushd $BUGS
    /usr/local/www/utils/bticket.sh $TICKET $SDK
    cd $TICKET

    # There's probably a better way to do this than creating a temporary file.
    touch tmp

    # Use double quotes to preserve line breaks.
    echo "$FIDDLE" > tmp

    sed -i '' -e "/Ext.onReady/ {
        r tmp
    }" index.html

    rm tmp
    popd
fi

###############################################################
# 1. Name the session the same as the ticket number.
# 2. cd to the appropriate SDK and create the new topic branch.
# 3. Split the window to be 80% of the total height.
# 4. Target the new pane and create the new ticket dir.
# 5. Attach to the session.
###############################################################
tmux has-session -t $TICKET 2>/dev/null
if [ $? -eq 1 ]; then
    tmux new-session -s $TICKET -n console -d
    tmux send-keys -t $TICKET 'cd $'$SDK C-m

    if $BRANCH; then
        tmux send-keys -t $TICKET 'git checkout -b '$TICKET C-m
    fi

    tmux send-keys 'clear' C-m
    tmux split-window -v -p 80 -t $TICKET
    tmux send-keys -t $TICKET:0.1 "cd $BUGS" C-m

    # Note if $FIDDLE is unset then we need to create the bug dir.
    if [ -z "$FIDDLE" ]; then
        tmux send-keys -t $TICKET:0.1 "bticket $TICKET $SDK" C-m
    fi

    tmux send-keys -t $TICKET:0.1 "cd $TICKET" C-m
    tmux send-keys -t $TICKET:0.1 'vim index.html' C-m
fi
tmux attach -t $TICKET

