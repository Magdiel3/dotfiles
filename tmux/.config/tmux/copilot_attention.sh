#!/bin/bash

# Track Copilot attention per pane and render the existing status-bar clock.
# Usage: copilot_attention.sh working|waiting|done|ack|clock [pane_id]
# Example: copilot_attention.sh done "$TMUX_PANE"

command -v tmux >/dev/null 2>&1 || exit 0
[[ -n ${TMUX:-} ]] || exit 0

focused_panes() {
    tmux list-clients -F '#{pane_id}' 2>/dev/null
}

acknowledge() {
    local pane
    while IFS= read -r pane; do
        [[ -n $pane ]] || continue
        if [[ $(tmux show-option -pqv -t "$pane" @copilot_attention 2>/dev/null) == done ]]; then
            tmux set-option -pu -t "$pane" @copilot_attention 2>/dev/null
        fi
    done < <(focused_panes)
}

refresh() {
    local client
    while IFS= read -r client; do
        [[ -n $client ]] && tmux refresh-client -S -t "$client" 2>/dev/null
    done < <(tmux list-clients -F '#{client_name}' 2>/dev/null)
}

case ${1:-} in
    working|waiting|done)
        pane=${2:-${TMUX_PANE:-}}
        [[ $pane =~ ^%[0-9]+$ ]] || exit 0
        if [[ $1 == working ]]; then
            tmux set-option -pu -t "$pane" @copilot_attention 2>/dev/null
        elif [[ $1 == done ]] && focused_panes | grep -Fxq -- "$pane"; then
            tmux set-option -pu -t "$pane" @copilot_attention 2>/dev/null
        else
            tmux set-option -p -t "$pane" @copilot_attention "$1" 2>/dev/null
        fi
        refresh
        ;;
    ack)
        acknowledge
        refresh
        ;;
    clock)
        acknowledge
        states=$(tmux list-panes -a -F '#{?pane_dead,,#{@copilot_attention}}' 2>/dev/null)
        color='#{@thm_blue}'
        if grep -Fxq waiting <<< "$states"; then
            color='#{@thm_yellow}'
        elif grep -Fxq done <<< "$states"; then
            color='#{@thm_green}'
        fi
        tmux display-message -p \
            "#[bg=#{@thm_bg},fg=$color]#{@round_left_separator}#[fg=#{@thm_bg},bg=$color]󰅐 %H:%M#[bg=#{@thm_bg},fg=$color]#{@round_right_separator}"
        ;;
esac

exit 0
