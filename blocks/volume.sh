#!/bin/bash


source "$(dirname $0)/_fa-icons.sh"

VOLUME=$(amixer sget Master | grep -E 'Playback.*%')
STATUS=$(<<< "$VOLUME" awk '{print $NF}' | tr -d '[]')
PERCENT=$(<<< "$VOLUME" grep Playback | grep -oE '[0-9]+%' | sort -u | head -n 1 | tr -d '%')

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
