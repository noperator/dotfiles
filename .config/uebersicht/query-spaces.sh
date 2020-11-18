#!/usr/bin/env bash

# Use yabai to query all spaces while filtering each space's list of windows
# to ignore hidden Microsoft Teams Notifications.

# Find yabai.
PATH="/usr/local/bin:$PATH"

# Get window IDs of hidden Teams notification windows.
TEAMS_NOTIFICATIONS=$(yabai -m query --windows | jq -r '[.[] | select(.title == "Microsoft Teams Notification") | .id] | unique | @csv')

# Get spaces while removing windows whose IDs match Teams notification
# windows.
yabai -m query --spaces | jq --arg teams_notifications "$TEAMS_NOTIFICATIONS" 'del(.[].windows[] | select(. | tostring | IN($teams_notifications)))'
