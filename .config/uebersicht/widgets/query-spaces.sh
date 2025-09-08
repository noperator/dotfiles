#!/usr/bin/env bash

# Use yabai to query all spaces while filtering each space's list of windows
# to ignore windows having certain characteristics.
#
# Note as of 17 Jan 2023: Sometimes, windows IDs are referenced in `--spaces`
# but _not_ in `--windows`. That means that we can't totally, confidently
# filter out all windows here. We can compensate for this by checking each
# space's `first-window` and `last-window` since it seems like when those are
# both 0, then there are no visible windows. I updated `spaces.coffee` to
# account for that (i.e., rather than checking `spaces['windows'].length`).
# This also requires cycling through each space after refreshing yabai so that
# the `(first|last)-window` keys will be populated, since that only seems to
# happen when you initially navigate to the space.
# - https://github.com/koekeishiya/yabai/issues/1367

# Find yabai.
PATH="/opt/homebrew/bin:$PATH"

# Get window IDs of hidden Teams windows and minimized windows.
# TEAMS_WINDOWS=$(yabai -m query --windows |
#     jq '[.[] | select(
#         (.title | test("^Microsoft Teams (Notification|Call)|Reminders?$"))
#         or
#         .minimized == 1
#         ) | .id] | unique')
# [[ -z "$TEAMS_WINDOWS" ]] && TEAMS_WINDOWS='[]'

# Get spaces while removing windows whose IDs match Teams windows.
# yabai -m query --spaces |
#     jq --argjson teams_windows "$TEAMS_WINDOWS" 'del(.[].windows[] | select(. | IN($teams_windows[])))' |
#     jo spaces=:/dev/stdin displays="$(yabai -m query --displays)"
# jo spaces="$(yabai -m query --spaces |
#     jq --argjson teams_windows $TEAMS_WINDOWS 'del(.[].windows[] | select(. | IN($teams_windows[])))')" displays="$(yabai -m query --displays)"
# { yabai -m query --spaces |
#     jo spaces=:/dev/stdin displays="$(yabai -m query --displays)"; } 2>/dev/null

{
    aerospace list-workspaces --all --json --format '%{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{monitor-name}'
    aerospace list-windows --all --json --format '%{window-id} %{window-title} %{window-is-fullscreen} %{app-bundle-id} %{app-name} %{app-pid} %{app-exec-path} %{app-bundle-path} %{workspace} %{workspace-is-focused} %{workspace-is-visible} %{monitor-id} %{monitor-appkit-nsscreen-screens-id} %{monitor-name}' | jq 'group_by(.workspace) | map({workspace: .[0].workspace, windows: map(.)})'
} | jq -s 'add | group_by(.workspace) | map(add)' | jo spaces=:/dev/stdin
