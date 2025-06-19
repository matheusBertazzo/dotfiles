#!/bin/bash

if tmux has-session -t quartz; then
	read -p 'Quartz session already exists, do you want to overwrite? (y/N) ' SHOULD_OVERWRITE

	if [[ $SHOULD_OVERWRITE != 'y' ]] then
		exit 1
	else
		tmux kill-session -t quartz
	fi
fi

tmux new -s quartz -d
tmux rename-window -t quartz nvim
tmux send-keys -t quartz "cd $TMUX_QOL_QUARTZ_CONTENT_PATH" C-m
tmux send-keys -t quartz 'nvim .' C-m

tmux new-window -t quartz
tmux rename-window -t quartz quartz-server
tmux send-keys -t quartz "cd $TMUX_QOL_QUARTZ_INSTALLATION_PATH" C-m
tmux send-keys -t quartz 'npx quartz build --serve' C-m

tmux select-window -t quartz:nvim
tmux attach -t quartz
