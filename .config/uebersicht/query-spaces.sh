#!/usr/bin/env bash

# Use yabai to query all spaces while filtering each space's list of windows
# to ignore windows having certain characteristics.

# Find yabai.
PATH="/opt/homebrew/bin:$PATH"

# Get window IDs of hidden Teams windows and minimized windows.
TEAMS_WINDOWS=$(yabai -m query --windows |
    jq '[.[] | select(
        (.title | test("^Microsoft Teams (Notification|Call)|Reminders?$"))
        or
        .minimized == 1
        ) | .id] | unique')
[[ -z "$TEAMS_WINDOWS" ]] && TEAMS_WINDOWS='[]'

# Get spaces while removing windows whose IDs match Teams windows.
yabai -m query --spaces |
    jq --argjson teams_windows "$TEAMS_WINDOWS" 'del(.[].windows[] | select(. | IN($teams_windows[])))'
