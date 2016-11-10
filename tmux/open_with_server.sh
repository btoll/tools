#!/bin/bash

###############################################################
# 1. Name the session the same as the file to be opened.
# 2. Start the node web server.
# 3. Split the window vertically (10% web server, 90% editor).
# 4. Load the file in the bottom pane.
# 5. Attach to the session.
###############################################################

if [ "$#" -eq 0 ]; then
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) Not enough arguments."
    echo "Usage: open_with_server <filename or pattern>"
    exit 0
else
    FILE="$1"

    # Since globs or anything could be entered as the file(s) to open,
    # let's set the session as the timestamp rather than as a name.
    SESSION=$(date "+%Y%m%d%H%M%S")
fi

tmux has-session -t $SESSION 2> /dev/null

if [ "$?" -eq 1 ]; then
    tmux new-session -s $SESSION -d
    tmux split-window -v -p 90 -t $SESSION
    tmux send-keys -t $SESSION:0.0 'clear && web_start' C-m
    tmux send-keys -t $SESSION:0.1 'vim '$FILE C-m
fi

tmux attach -t $SESSION

