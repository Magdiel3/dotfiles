#!/bin/bash

status=$(tmux show-environment -g connection_status 2>/dev/null | cut -d= -f2)
resp=$(tmux show-environment -g connection_response_ms 2>/dev/null | cut -d= -f2)

SEP='━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

if [ "$status" = "1" ]; then
    echo -e "\033[1;32m${SEP}\033[0m"
    echo -e "\033[1;32m ✓  GitHub REACHABLE\033[0m"
    echo -e "\033[0;32m Response: ${resp}ms\033[0m"
    echo -e "\033[1;32m${SEP}\033[0m"
else
    echo -e "\033[1;31m${SEP}\033[0m"
    echo -e "\033[1;31m ✗  GitHub UNREACHABLE\033[0m"
    echo -e "\033[0;31m Connection failed\033[0m"
    echo -e "\033[1;31m${SEP}\033[0m"
fi

echo ''
echo 'Press any key or wait 3s...'

sleep 3 &
SLEEP_PID=$!
read -r -t 3 -n 1 < /dev/tty 2>/dev/null && kill "$SLEEP_PID" 2>/dev/null
wait "$SLEEP_PID" 2>/dev/null
