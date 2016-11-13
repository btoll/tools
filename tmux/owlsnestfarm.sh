#!/bin/bash

SESSION=owlsnestfarm

tmux has-session -t $SESSION 2> /dev/null

if [ "$?" -eq 1 ]; then
    tmux new-session -s $SESSION -d
    tmux split-window -h -t $SESSION
    tmux send-keys -t $SESSION:0.1 'clear && ssh owlsnestfarm' C-m
fi

tmux attach -t $SESSION

