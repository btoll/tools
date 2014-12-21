#!/bin/bash

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
        --ticket|-ticket|-t) shift; TICKET=$1 ;;
        --version|-version|-v) shift; VERSION=$1 ;;
    esac
    shift
done

SDK=SDK${VERSION:-5}

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
    tmux send-keys -t $TICKET 'cd $'$SDK'; git checkout -b '$TICKET'; clear' C-m
    tmux split-window -v -p 80 -t $TICKET
    tmux send-keys -t $TICKET:0.1 "cd $BUGS; bticket $TICKET $SDK; cd $TICKET; vim index.html" C-m
fi
tmux attach -t $TICKET
