#!/bin/bash

source "$(dirname $0)/_fa-icons.sh"

VOLUME=$(amixer sget Master)
STATUS=$(<<< "$VOLUME" awk '/dB/ {print $NF}' | tr -d '[]')
PERCENT=$(<<< "$VOLUME" awk '/dB/ {print $4}' | tr -d '[]%')

if [[ "$STATUS" == 'off' ]]; then
    ICON='volume-mute'
elif   [[ "$PERCENT" -eq 0 ]]; then
    ICON='volume-off'
elif [[ "$PERCENT" -lt 50 ]]; then
    ICON='volume-down'
else
    ICON='volume-up'
fi

print_fa_icon "$ICON"
echo "$PERCENT%"
