#!/bin/bash

# Reads laptop battery level pushed by the SSH client (laptop) to a shared file.
# The file is expected to contain: "<percentage> <status>"
# where status is "charging" or "discharging".
#
# The file is written by a script on the laptop machine via SSH.
# If the file is missing or stale (>5 min old), a "?" indicator is shown.

BATTERY_FILE="$HOME/.local/share/laptop_battery"
STALE_THRESHOLD=300 # seconds

if [[ ! -f "$BATTERY_FILE" ]]; then
    echo "󰍛 ?"
    exit 0
fi

# Check if data is stale
file_age=$(( $(date +%s) - $(date -r "$BATTERY_FILE" +%s) ))
if (( file_age > STALE_THRESHOLD )); then
    echo "󰍛 ?"
    exit 0
fi

read -r pct status < "$BATTERY_FILE"

if [[ ! "$pct" =~ ^[0-9]{1,3}$ ]] || (( 10#$pct > 100 )) || \
   [[ "$status" != "charging" && "$status" != "discharging" ]]; then
    echo "󰍛 ?"
    exit 0
fi
pct=$((10#$pct))

# Pick battery icon based on level and charging state
if [[ "$status" == "charging" ]]; then
    icon="󰂄"
elif (( pct <= 10 )); then
    icon="󰁺"
elif (( pct <= 25 )); then
    icon="󰁻"
elif (( pct <= 50 )); then
    icon="󰁽"
elif (( pct <= 75 )); then
    icon="󰁿"
else
    icon="󰁹"
fi

echo "󰍛 ${icon} ${pct}%"
