#!/bin/bash

# This check needs to be called periodically
#
# You could do `crontab -e` and add the following:
# `*/1 * * * * $HOME/.config/tmux/check_github_reachable.sh`

response_time=$(curl -o /dev/null -s --max-time 2 -w '%{time_total}' https://github.com)
if [ $? -eq 0 ]; then
    ms=$(awk "BEGIN {printf \"%d\", $response_time * 1000}")
    tmux set-environment -g connection_status "1"
    tmux set-environment -g connection_response_ms "$ms"
else
    tmux set-environment -g connection_status "0"
    tmux set-environment -g connection_response_ms ""
fi
