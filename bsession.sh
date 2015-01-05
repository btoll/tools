#!/bin/bash
# TODO: allow choice of split.
# TODO: allow custom command to come from an env var?

# NOTE this script uses GNU tools like sed and tac.
# To install on Mac -> brew install coreutils.

BASE_DIR=
BRANCH=true
# Let's set a default command.
COMMAND=
CREATE_DIR=true
EXISTS=false
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
    echo "--command, -command, -c : The command to run if a bug directory is not to be created. This will be run in the bottom pane."
    echo "                          Note that the presence of this flag trumps everything else."
    echo "                          Defaults to 'vim -c :CtrlP'."
    echo
    echo "--fiddle, -fiddle, -f   : Location of Fiddle to download using curl and paste into index.html in new bug dir."
    echo
    echo "--no-branch             : Don't create a new git topic branch (by default it will)."
    echo
    echo "--no-dir                : Don't create a new bug directory (by default it will)."
    echo
    echo "--ticket, -ticket, -t   : The bug ticket number."
    echo
    echo "--version, -version, -v : The framework major version. Defaults to 5."
    echo
}

if [ $# -eq 0 ]; then
    usage
    exit 0
fi

# Swap out for user-provided options if given.
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        -help|-h) usage; exit 0 ;;
        --command|-command|-c) shift; COMMAND=$1 ;;
        --fiddle|-fiddle|-f) shift; FIDDLE=$1 ;;
        --no-branch) BRANCH=false ;;
        --no-dir) CREATE_DIR=false ;;
        --ticket|-ticket|-t) shift; TICKET=$1 ;;
        --version|-version|-v) shift; VERSION=$1 ;;
    esac
    shift
done

SDK=SDK${VERSION:-5}

# If $FIDDLE is set, then let's go through the process of creating the bug dir,
# downloading the Fiddle preview, extracting our best-guess-attempt at the code
# body and finally slapping that into the new index.html.
#
# Note to only download a Fiddle if the flag is set, we're to create the bug dir AND there's no custom command!
if [ -n "$FIDDLE" ] && $CREATE_DIR && [ -z "$COMMAND" ] ; then
    # Let's re-use and re-define $FIDDLE.
    #
    # Let's accept either a regular Fiddle URL or a preview Fiddle URL.
    BASE_DIR=$(basename $FIDDLE)
    if [ "$BASE_DIR" != "preview" ]; then
        # Rename in this form: https://fiddle.sencha.com/fiddle/da1/preview
        FIDDLE="https://fiddle.sencha.com/fiddle/$BASE_DIR/preview"
    fi

    # Then download and extract just what we need.
    #
    # Here we will extract every line after the launch method and before the closing <script> tag.
    # -n                       -> don't print
    # '/launch/, /<\/script>/  -> match range, I guess you knew it already
    # {                        -> if in this range
    #     /launch/             -> and line matches /Screenshot/
    #         {d;p;n};         -> do not print the first line (the match), print the next line and read next row
    #     /<\/script>/         -> if line matches "<\/script>"
    #         q;               -> quit, we have done all printing
    #     p                    -> if we come to here, print the line
    # }
    #
    # http://stackoverflow.com/a/744093
    # There's probably a better way to do this than creating a temporary file.
    #
    # Let's first cd to a dir where we know we have write permissions.
    pushd $BUGS
    curl $FIDDLE | gsed -n '/launch/,/<\/script>/{/launch/{d;p;n};/<\/script>/{q};p}' > foo

    # We still need to delete the last n lines in this file.
    gtac foo | sed '1,4d' | gtac > tmp

    /usr/local/www/utils/bticket.sh $TICKET $SDK
    cd $TICKET

    sed -i '' -e '/Ext.onReady/ {
        r ../foo
    }' index.html

    rm ../foo
    popd
fi

###############################################################
# 1. Name the session the same as the ticket number.
# 2. cd to the appropriate SDK and create the new topic branch.
# 3. Split the window to be 55% of the total width.
# 4. Target the new pane and create the new ticket dir.
# 5. Attach to the session.
###############################################################
tmux has-session -t $TICKET 2>/dev/null
if [ $? -eq 1 ]; then
    tmux new-session -s $TICKET -d
    tmux send-keys -t $TICKET 'cd $'$SDK C-m

    if $BRANCH; then
        # Here we need to check if this branch already exists. If so, don't pass
        # the -b flag when the branch is checked out.
        #
        # We'll need to cd to the correct repo to check for existence.
        pushd /usr/local/www/$SDK
        EXISTS="$(git show-ref refs/heads/"$TICKET")"
        popd

        if [ -z "$EXISTS" ]; then
            NEW_BRANCH="-b"
        fi

        tmux send-keys -t $TICKET 'git checkout '$NEW_BRANCH' '$TICKET C-m
    fi

    tmux send-keys 'clear' C-m
    tmux split-window -h -p 55 -t $TICKET
    tmux send-keys -t $TICKET:0.1 "cd $BUGS" C-m

    # Note if $FIDDLE is unset, we want a new ticket dir AND there's no custom command, then let's create the bug dir.
    if [ -z "$FIDDLE" ] && $CREATE_DIR && [ -z "$COMMAND" ]; then
        tmux send-keys -t $TICKET:0.1 "bticket $TICKET $SDK" C-m
        tmux send-keys -t $TICKET:0.1 "cd $TICKET" C-m
        tmux send-keys -t $TICKET:0.1 'vim index.html' C-m
    else
    # Else cd again to the appropriate SDK and run the $COMMAND.
        COMMAND=${COMMAND:-"vim -c :CtrlP"}
        tmux send-keys -t $TICKET:0.1 'cd $'$SDK C-m
        #tmux send-keys -t $TICKET:0.1 'vim -c :CtrlP' C-m
        tmux send-keys -t $TICKET:0.1 "$COMMAND" C-m
    fi
fi
tmux attach -t $TICKET

