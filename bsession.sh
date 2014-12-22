#!/bin/bash

BRANCH=true
FIDDLE=
SDK=
TEMP=foo
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
        --no-branch) shift; BRANCH=false ;;
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
    tmux send-keys -t $TICKET 'cd $'$SDK C-m

    if $BRANCH; then
        tmux send-keys -t $TICKET 'git checkout -b '$TICKET C-m
    fi

    tmux send-keys 'clear' C-m
    tmux split-window -v -p 80 -t $TICKET
    #tmux send-keys -t $TICKET:0.1 "cd $BUGS; bticket $TICKET $SDK; cd $TICKET; vim index.html" C-m
    tmux send-keys -t $TICKET:0.1 "cd $BUGS; bticket $TICKET $SDK; cd $TICKET" C-m

#    # Let's re-use and re-define $FIDDLE.
#    FIDDLE=$(curl https://fiddle.sencha.com/fiddle/da1/preview | sed -e '1,/launch/d' -e '/<\/script>/,$d')
#    cd $BUGS$TICKET
#    #sed -i '' -e 's/\/\/REPLACE ME/'$FIDDLE'/' index.html
#    touch $TEMP
#    cat $FIDDLE > $TEMP
#
#    sed "/\/\/REPLACE ME/ {
#        r $TEMP
#        d
#    }" index.html
#
#    rm $TEMP

    tmux send-keys -t $TICKET:0.1 "vim index.html" C-m
fi
tmux attach -t $TICKET

