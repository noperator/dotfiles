#!/bin/bash

source "$(dirname $0)/_fa-icons.sh"

VOLUME=$(amixer sget Master)
STATUS=$(<<< "$VOLUME" awk '/dB/ {print $NF}' | tr -d '[]')
PERCENT=$(<<< "$VOLUME" awk '/dB/ {print $4}' | tr -d '[]%')

if [[ "$STATUS" == 'off' ]]; then
    ICON='VOLUME_MUTE'
elif   [[ "$PERCENT" -eq 0 ]]; then
    ICON='VOLUME_OFF'
elif [[ "$PERCENT" -lt 50 ]]; then
    ICON='VOLUME_DOWN'
else
    ICON='VOLUME_UP'
fi

print_fa_icon "$ICON"
echo "$PERCENT%"
