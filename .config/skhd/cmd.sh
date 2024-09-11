#!/bin/bash

KEYS="$1"

case "$KEYS" in
k)
    if [[ $(yabai -m query --windows --window | jq -r '.app') =~ ^(Slack|Preview|Arc|Todoist|Cursor)$ ]]; then
        skhd --key 'cmd + ctrl - t'
        skhd --key 'cmd - k'
        skhd --key 'cmd + ctrl - t'
    else
        yabai -m window --focus north
    fi
    ;;
l)
    if [[ $(yabai -m query --windows --window | jq -r '.app') =~ ^(Cursor)$ ]]; then
        skhd --key 'cmd + ctrl - t'
        skhd --key 'cmd - l'
        skhd --key 'cmd + ctrl - t'
    else
        yabai -m window --focus east
    fi
    ;;
esac

# case $(yabai -m query --windows --window | jq -r '.app') in
# Slack)
#     skhd --key 'cmd + ctrl - t'
#     skhd --key 'cmd - k'
#     skhd --key 'cmd + ctrl - t'
#     ;;
# *)
#     yabai -m window --focus north
#     ;;
# esac
