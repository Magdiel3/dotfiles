#!/bin/bash
# fmt-dirname.sh: Format a directory basename for the tmux status bar.
# Transforms _copilot_worktree_<REPO>_<N> → WT<N>_<REPO>
# Usage: fmt-dirname.sh <basename> [max_length]

d="${1:-}"
max="${2:-32}"

if [[ ! "$max" =~ ^[0-9]+$ ]] || (( max < 3 )); then
    echo "Maximum length must be an integer of at least 3." >&2
    exit 1
fi

if [[ "$d" =~ ^_copilot_worktree_(.+)_([0-9]+)$ ]]; then
    repo="${BASH_REMATCH[1]}"
    n="${BASH_REMATCH[2]}"
    d="WT${n}_${repo}"
fi

if (( ${#d} > max )); then
    d="${d:0:$((max - 3))}..."
fi

printf '%s' "$d"
