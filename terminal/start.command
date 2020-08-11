#!/bin/bash

notify() { osascript -e 'display notification "'"$1"'" with title "'"Start Apps"'"'; }

for APP in \
'Microsoft Outlook' \
'Microsoft Teams' \
Slack \
; do
    if ! [[ $(pgrep -f "$APP.app") ]]; then
        notify "Starting $APP"
        open -a "$APP"
    fi
done
