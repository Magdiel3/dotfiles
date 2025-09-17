#!/bin/bash

# This check needs to be called periodically
#
# You could do `crontab -e` and add the following:
# `*/1 * * * * $HOME/.config/tmux/check_github_reachable.sh`

if curl -s --max-time 2 https://github.com > /dev/null; then
    tmux set-environment -g connection_status "1"
else
    tmux set-environment -g connection_status "0"
fi
