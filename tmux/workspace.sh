#!/bin/bash

usage() {
    echo "#"
    echo "# Creates a workspace that looks like:"
    echo "#"
    echo "#   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "#   + ~:$                          | ~:$                          +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +                              |                              +"
    echo "#   +-------------------------------------------------------------+"
    echo "#   + ~:$                                                         +"
    echo "#   +                                                             +"
    echo "#   +                                                             +"
    echo "#   +                                                             +"
    echo "#   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "#"
    echo "# Optionally, pass a path for all windows:"
    echo "#"
    echo "#       workspace \$GOPATH/src/github.com/btoll"
    echo "#"
}

if [ "$1" == "help" ]; then
    usage
    exit
fi

# cd to a given path or default to staying at cwd.
DIR=${1:-$(pwd)}
SESSION=$(date "+%Y%m%d%H%M%S")

tmux has-session -t $SESSION 2> /dev/null

if [ "$?" -eq 1 ]; then
    tmux new-session -s $SESSION -d
    tmux split-window -p 20 -t $SESSION

    # Select first pane before opening another horizontal one.
    tmux select-pane -t 0
    tmux split-window -h -t $SESSION

    tmux send-keys -t $SESSION:0.0 'cd '$DIR'; clear' C-m
    tmux send-keys -t $SESSION:0.1 'cd '$DIR'; clear' C-m
    tmux send-keys -t $SESSION:0.2 'cd '$DIR'; clear' C-m
fi

tmux attach -t $SESSION

