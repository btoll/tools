#!/bin/bash

usage() {
    echo "Usage: $0 [args]"
    echo
    echo "Args:"
    echo "--dir, -dir, -d         : Optional. Creates each pane in this directory."
    echo
    echo "--session, -session, -s : Optional. The session name."
    echo
    echo "Creates a workspace that looks like:"
    echo
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
    echo
}

while [ "$#" -gt 0 ]; do
    OPT="$1"
    case $OPT in
        --dir|-dir|-d) shift; DIR=$1 ;;
        --session|-session|-s) shift; SESSION=$1 ;;
        --help|-help|-h) usage; exit 0 ;;
    esac
    shift
done

# Set some reasonable defaults.
DIR=${DIR:-$(pwd)}
SESSION=${SESSION:-$(date "+%Y%m%d%H%M%S")}

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

    tmux send-keys -t $SESSION:0.1 'eval "$(ssh-agent -s)" && ssh-add ~/.ssh/debian' C-m
fi

tmux attach -t $SESSION

