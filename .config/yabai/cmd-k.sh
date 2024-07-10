#!/bin/bash

if [[ $(yabai -m query --windows --window | jq -r '.app') =~ ^(Slack|Preview|Arc|Todoist)$ ]]; then
    skhd --key 'cmd + ctrl - t'
    skhd --key 'cmd - k'
    skhd --key 'cmd + ctrl - t'
else
    yabai -m window --focus north
fi

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
