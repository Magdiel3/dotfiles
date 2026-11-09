#!/bin/bash

# copilot_usage.sh — Copilot premium request usage tracker
#
# Usage:
#   copilot_usage.sh              Dashboard popup (auto-fetches usage via gh API)
#   copilot_usage.sh --history    Terminal bar chart of daily deltas for current month
#   copilot_usage.sh --record     Headless: fetch and append to log (for cron jobs)
#
# ── Prerequisites ─────────────────────────────────────────────────────────────
#
#   1. gh CLI (https://cli.github.com/) installed and authenticated:
#        gh auth login   # follow prompts to log in with github.com
#        gh auth status  # verify you are logged in
#
#      No special token scopes or PAT are needed — the standard OAuth login is
#      sufficient.  For Copilot Business seats, your organization must have CLI
#      access enabled (Settings › Copilot › Enable Copilot CLI).
#
#   2. python3  — used for JSON parsing and fallback calendar math.
#      Available by default on virtually all Linux/macOS systems.
#
# ── How quota is fetched ──────────────────────────────────────────────────────
#
#   The script calls an internal GitHub API endpoint:
#
#     gh api /copilot_internal/user
#
#   This returns JSON that includes:
#     quota_snapshots.premium_interactions.percent_remaining  → e.g. 71.0
#     quota_snapshots.premium_interactions.entitlement        → e.g. 300
#     quota_snapshots.premium_interactions.quota_remaining    → e.g. 213
#     quota_reset_date                                        → e.g. 2026-06-01
#
#   Usage % displayed = 100 − percent_remaining
#
#   NOTE: /copilot_internal/user is an undocumented internal endpoint (used by
#   the Copilot CLI itself to populate its statusline quota display).  It is not
#   part of the official GitHub REST API and may change without notice.
#
# ── Fallback behaviour ────────────────────────────────────────────────────────
#
#   If the API call fails for any reason (no network, gh not installed, not
#   authenticated, endpoint changed), the script falls back to a manual input
#   prompt where you can type the percentage shown on:
#     https://github.com/settings/copilot/features
#
# ── Data file ─────────────────────────────────────────────────────────────────
#
#   Every successful dashboard run appends one line to  ~/.copilot_usage:
#
#     YYYY-MM-DD,<usage_pct>
#
#   e.g.  2026-05-13,29.0
#
#   This file is used by --history mode to render the bar chart.  It persists
#   across months; old entries are never removed.  You can safely delete or edit
#   it by hand — the script recreates it on next run.
#
# ── Sharing / adapting for other devs ────────────────────────────────────────
#
#   1. Install gh CLI and run `gh auth login`.
#   2. Copy or stow this script to any location on your PATH (or reference it
#      directly from your tmux.conf display-popup call).
#   3. No environment variables or config files beyond ~/.copilot_usage are
#      required.  The script is self-contained.
#   4. This endpoint is hosted on github.com, not GitHub Enterprise Server.
#
# ── Scheduled background tracking (systemd timer) ────────────────────────────
#
#   Use the --record flag to record usage silently without a popup — suitable
#   for scheduled jobs.  It fetches the current usage and appends to
#   ~/.copilot_usage with no output.  Exit code 0 = success, 1 = API failure.
#   The gh call times out after 20s and never prompts for input.
#
#   A systemd user timer runs it every 2 hours plus at 23:55 to bracket
#   midnight.  Units live in ~/.config/systemd/user/copilot-usage.{service,timer}.
#
#     systemctl --user daemon-reload
#     systemctl --user enable --now copilot-usage.timer
#     systemctl --user list-timers copilot-usage.timer   # next run
#     journalctl --user -u copilot-usage.service          # failures
#
#   Notes:
#   • If gh has problems, unset GH_TOKEN to avoid conflicts with other tokens.
#   • Persistent=true runs one catch-up record after boot/resume if a
#     scheduled run was missed.
# ─────────────────────────────────────────────────────────────────────────────

USAGE_FILE="${HOME}/.copilot_usage"
BAR_WIDTH=30
SEP='━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

# ─── Color codes ────────────────────────────────────────────────────────────
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
DIM='\033[2;37m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── Helper: render a progress bar ──────────────────────────────────────────
# render_bar <pct> <color_code>
render_bar() {
    local pct="$1"
    local color="$2"
    local filled empty i bar=""
    filled=$(awk "BEGIN { n=int($pct/100*$BAR_WIDTH+0.5); print (n>$BAR_WIDTH?$BAR_WIDTH:n) }")
    empty=$(( BAR_WIDTH - filled ))
    for (( i=0; i<filled; i++ )); do bar+="█"; done
    for (( i=0; i<empty; i++ )); do bar+="░"; done
    printf "${color}%s${RESET}" "$bar"
}

# ─── Helper: days in a given month ──────────────────────────────────────────
# days_in_month YYYY MM
days_in_month() {
    date -d "$1-$2-01 + 1 month - 1 day" +%d 2>/dev/null \
        || python3 -c "import calendar; print(calendar.monthrange($1,$2)[1])"
}

# ─── Load last entry from log ───────────────────────────────────────────────
# Sets: last_date, last_pct, last_month
load_last_entry() {
    last_date="" last_pct="0" last_month=""
    if [[ -f "$USAGE_FILE" ]]; then
        local last_line
        last_line=$(grep -v '^\s*$' "$USAGE_FILE" | tail -1)
        if [[ -n "$last_line" ]]; then
            last_date="${last_line%%,*}"
            last_pct="${last_line##*,}"
            last_month="${last_date:0:7}"   # YYYY-MM
        fi
    fi
}

# ─── Fetch live usage from GitHub API ───────────────────────────────────────
# Prints usage percentage (≥0, can exceed 100 in overage) and credits used.
# returns 1 on failure.
# Requires: gh CLI authenticated with github.com.
fetch_usage() {
    local raw
    # Bound the call and block any interactive prompt so a stuck request never hangs.
    raw=$(GH_PROMPT_DISABLED=1 timeout 20 gh api --hostname github.com /copilot_internal/user --cache 0 \
        </dev/null 2>/dev/null) || return 1
    python3 - <<'EOF' "$raw"
import json, math, sys
try:
    d = json.loads(sys.argv[1])
    snap = d['quota_snapshots']['premium_interactions']
    pct_remaining = float(snap['percent_remaining'])
    credits = snap.get('credits_used')
    if pct_remaining > 0:
        used = 100.0 - pct_remaining
    else:
        # percent_remaining caps at 0 in overage; compute true usage from
        # quota_remaining (negative when over limit) and entitlement.
        entitlement = float(snap['entitlement'])
        quota_remaining = float(snap['quota_remaining'])
        if entitlement <= 0:
            sys.exit(1)
        used = (entitlement - quota_remaining) / entitlement * 100.0
    if not math.isfinite(used) or used < 0:
        sys.exit(1)
    cost = "" if credits is None else f"{float(credits):.2f}"
    print(f"{used:.1f}|{cost}")
except Exception:
    sys.exit(1)
EOF
}

fetch_usage_pct() {
    local result
    result=$(fetch_usage) || return 1
    echo "${result%%|*}"   # return only the usage percentage
}

show_history() {
    local cur_month cur_year cur_mon_num
    cur_month=$(date +%Y-%m)
    cur_year=$(date +%Y)
    cur_mon_num=$(date +%-m)
    local month_name
    month_name=$(date +"%B %Y")
    local total_days
    total_days=$(days_in_month "$cur_year" "$cur_mon_num")

    # Read entries for current month into parallel arrays
    # Supports both old format (YYYY-MM-DD,pct) and new (YYYY-MM-DDTHH:MM:SS±HH:MM,pct)
    local -a entry_days entry_pcts
    if [[ -f "$USAGE_FILE" ]]; then
        while IFS=, read -r timestamp pct; do
            [[ "${timestamp:0:7}" == "$cur_month" ]] || continue
            entry_days+=( "${timestamp:8:2}" )   # chars 8-9 are always DD in both formats
            entry_pcts+=( "$pct" )
        done < "$USAGE_FILE"
    fi

    if [[ ${#entry_days[@]} -eq 0 ]]; then
        echo -e "${DIM}No entries for ${month_name}.${RESET}"
        return
    fi

    # ── Pre-compute weekend flags for all days (single pass, no per-day syscalls) ──
    local -a is_wknd wknd_str=""
    for (( d=1; d<=total_days; d++ )); do
        dow=$(date -d "$(printf '%d-%02d-%02d' "$cur_year" "$cur_mon_num" "$d")" +%u 2>/dev/null)
        if (( dow >= 6 )); then
            is_wknd[$d]=1; wknd_str+="1"
        else
            is_wknd[$d]=0; wknd_str+="0"
        fi
    done

    # ── Build daily_delta[1..total_days] via awk ─────────────────────────────
    # Pass entry arrays as a string to awk: "day:pct day:pct ..."
    local entries_str=""
    for (( i=0; i<${#entry_days[@]}; i++ )); do
        entries_str+="${entry_days[$i]}:${entry_pcts[$i]} "
    done

    # awk computes per-day delta using pre-computed weekend string (no date syscalls)
    local awk_out
    awk_out=$(awk -v entries="$entries_str" -v total="$total_days" -v wknd="$wknd_str" '
    function is_weekend(d) { return substr(wknd, d, 1) == "1" }
    function count_weekdays(d1, d2,    n, d) {
        n = 0
        for (d = d1; d <= d2; d++)
            if (!is_weekend(d)) n++
        return n
    }
    BEGIN {
        n = split(entries, pairs, " ")
        j = 0
        for (i = 1; i <= n; i++) {
            if (pairs[i] == "") continue
            split(pairs[i], kv, ":")
            days[++j]  = kv[1]+0
            pcts[j]    = kv[2]+0
        }
        # initialise all days to 0
        for (d = 1; d <= total; d++) delta[d] = 0

        prev_pct  = 0
        prev_day  = 0

        for (i = 1; i <= j; i++) {
            d   = days[i]
            pct = pcts[i]
            diff = pct - prev_pct

            if (prev_day == 0) {
                # first entry: all delta goes to entry day
                delta[d] += diff
            } else if (d == prev_day) {
                # same-day update (e.g. from --record): accumulate on this day
                delta[d] += diff
            } else if (d == prev_day + 1) {
                # consecutive day — all delta on this day
                delta[d] += diff
            } else {
                # gap: check if entry day is weekend (explicit entry on weekend)
                if (is_weekend(d)) {
                    # explicit weekend entry: give it the full diff
                    delta[d] += diff
                } else {
                    # distribute across weekdays in gap (prev_day+1 .. d)
                    wd = count_weekdays(prev_day+1, d)
                    if (wd == 0) wd = 1
                    share = diff / wd
                    for (gd = prev_day+1; gd <= d; gd++) {
                        if (!is_weekend(gd)) delta[gd] += share
                    }
                }
            }
            prev_pct = pct
            prev_day = d
        }
        for (d = 1; d <= total; d++) printf "%.4f\n", delta[d]
    }')

    # ── Load deltas into bash array and find max ──────────────────────────────
    local -a deltas
    readarray -t deltas <<< "$awk_out"

    local max_delta
    max_delta=$(printf '%s\n' "${deltas[@]}" | awk 'BEGIN{m=0} {if($1>m)m=$1} END{print m}')

    local chart_height=15
    if ! awk "BEGIN { exit ($max_delta == 0) }"; then
        echo -e "${DIM}No usage recorded for ${month_name}.${RESET}"
        return
    fi

    # ── Print chart ──────────────────────────────────────────────────────────
    echo ""
    printf "${BOLD}  Copilot Daily Usage — %s${RESET}    max: %.1f%%/day\n" \
        "$month_name" "$max_delta"
    echo ""

    # Build deltas string and wknd string to pass to awk for chart rendering
    local deltas_str=""
    for d in "${deltas[@]}"; do deltas_str+="$d "; done

    # Single awk call renders all chart rows and axes
    local CYAN_ESC=$'\033[1;36m' DIM_ESC=$'\033[2;37m' RESET_ESC=$'\033[0m'
    awk -v deltas="$deltas_str" -v total="$total_days" -v wknd="$wknd_str" \
        -v max_d="$max_delta" -v height="$chart_height" \
        -v CYA="$CYAN_ESC" -v DIM="$DIM_ESC" -v RST="$RESET_ESC" '
    BEGIN {
        n = split(deltas, dv, " ")
        for (row = height; row >= 1; row--) {
            thresh = max_d * row / height
            printf "  %4.1f \xe2\x94\x82", max_d * row / height
            for (d = 1; d <= total; d++) {
                val  = (d <= n) ? dv[d]+0 : 0
                fill = (val >= thresh) ? 1 : 0
                wk   = (substr(wknd, d, 1) == "1") ? 1 : 0
                if (wk) {
                    printf "%s%s%s ", DIM, (fill ? "\xe2\x96\x93\xe2\x96\x93" : "  "), RST
                } else {
                    printf "%s%s%s ", (fill ? CYA : ""), (fill ? "\xe2\x96\x88\xe2\x96\x88" : "  "), (fill ? RST : "")
                }
            }
            printf "\n"
        }
        # Baseline
        printf "       \xe2\x94\x94"
        for (d = 1; d <= total; d++) printf "\xe2\x94\x80\xe2\x94\x80\xe2\x94\x80"
        printf "\n"
        # Day numbers
        printf "        "
        for (d = 1; d <= total; d++) printf "%2d ", d
        printf "\n"
    }'
    echo ""
    printf "  ${CYAN}██${RESET} = weekday    ${DIM}▓▓${RESET} = weekend"
    read -r -n 1 < /dev/tty 2>/dev/null
}

# ─── RECORD MODE (headless — for cron) ───────────────────────────────────────
# Fetches current usage and appends to USAGE_FILE with no output.
# Exit 0 on success, 1 on API failure (cron logs stderr automatically).
show_record() {
    local pct
    pct=$(fetch_usage_pct) || {
        echo "$(basename "$0") --record: failed to fetch usage from GitHub API" >&2
        exit 1
    }
    local now
    now=$(date -Iseconds)
    echo "${now},${pct}" >> "$USAGE_FILE"
}


show_dashboard() {
    load_last_entry

    local cur_month cur_year cur_mon_num cur_day total_days
    cur_month=$(date +%Y-%m)
    cur_year=$(date +%Y)
    cur_mon_num=$(date +%-m)
    cur_day=$(date +%-d)
    total_days=$(days_in_month "$cur_year" "$cur_mon_num")

    # ── Print header ─────────────────────────────────────────────────────────
    echo -e "${BOLD}${SEP}${RESET}"
    echo -e "${BOLD}  Copilot Usage Tracker${RESET}"
    echo -e "${BOLD}${SEP}${RESET}"

    # ── Auto-fetch usage % from GitHub API ───────────────────────────────────
    local input_pct input_usage cur_cost fetched=0
    printf " ${DIM}Fetching usage from GitHub...${RESET}"
    if input_usage=$(fetch_usage); then
        fetched=1
    fi
    printf "\r%-48s\r" " "   # clear the "Fetching..." line
    if (( fetched )); then
        input_pct="${input_usage%%|*}"   # extract only the usage percentage
        cur_cost="${input_usage##*|}"
        if [[ -n "$cur_cost" ]]; then
            cur_cost=$(awk "BEGIN { printf \"%.2f\", $cur_cost / 100 }")
        fi
    else
        # ── Fallback: manual input prompt ────────────────────────────────────
        local default_pct="0"
        if [[ -n "$last_month" && "$last_month" == "$cur_month" ]]; then
            default_pct="$last_pct"
        fi
        printf " Enter usage %% [%s]: " "$default_pct"
        read -r input_pct
        [[ -z "$input_pct" ]] && input_pct="$default_pct"

        # Validate: must match a number pattern and be in 0–100
        if ! [[ "$input_pct" =~ ^[0-9]+(\.[0-9]+)?$ ]] || \
           ! awk "BEGIN { exit !($input_pct >= 0 && $input_pct <= 100) }" 2>/dev/null; then
            echo -e "\n${RED} Invalid input: '$input_pct'. Must be a number between 0 and 100.${RESET}\n"
            sleep 3
            return 1
        fi
    fi

    # ── Persist entry (append — multiple entries per day are intentional) ─────
    local now
    now=$(date -Iseconds)
    echo "${now},${input_pct}" >> "$USAGE_FILE" || return 1

    # ── Compute metrics ──────────────────────────────────────────────────────
    local month_pct usage_pct delta color status_icon status_word
    month_pct=$(awk "BEGIN { printf \"%.1f\", $cur_day / $total_days * 100 }")
    usage_pct=$(awk "BEGIN { printf \"%.1f\", $input_pct + 0 }")
    delta=$(awk "BEGIN { printf \"%.1f\", $usage_pct - $month_pct }")

    # Color based on delta
    if awk "BEGIN { exit !($delta <= 0) }"; then
        color="$GREEN"; status_icon="✓"; status_word="Under budget"
    elif awk "BEGIN { exit !($delta <= 10) }"; then
        color="$YELLOW"; status_icon="⚠"; status_word="Slightly over"
    else
        color="$RED"; status_icon="✗"; status_word="Over budget"
    fi

    local abs_delta
    abs_delta=$(awk "BEGIN { d=$delta; printf \"%.1f\", (d<0?-d:d) }")

    # ── Render dashboard ─────────────────────────────────────────────────────
    echo ""
    printf " Usage:  "; render_bar "$usage_pct" "$color";   printf "  ${color}%5s%%${RESET}\n" "$usage_pct"
    printf " Month:  "; render_bar "$month_pct" "$BLUE";    printf "  ${BLUE}%5s%%${RESET}\n" "$month_pct"
    echo -e "${BOLD}${SEP}${RESET}"
    printf " Status: ${color}%s %s by %s%%${RESET}\n" "$status_icon" "$status_word" "$abs_delta"
    if [[ -n "$cur_cost" ]]; then
        printf " Spent:  ${color}  $%s USD${RESET}\n" "$cur_cost"
    fi
    echo -e "${BOLD}${SEP}${RESET}"

    # ── Auto-close ───────────────────────────────────────────────────────────
    sleep 3 &
    SLEEP_PID=$!
    read -r -t 3 -n 1 < /dev/tty 2>/dev/null && kill "$SLEEP_PID" 2>/dev/null
    wait "$SLEEP_PID" 2>/dev/null
}

# ─── Entry point ─────────────────────────────────────────────────────────────
case "${1:-}" in
    --history|-h) show_history ;;
    --record|-r)  show_record ;;
    "")           show_dashboard ;;
    *) echo "Usage: $(basename "$0") [--history | --record]" >&2; exit 1 ;;
esac
