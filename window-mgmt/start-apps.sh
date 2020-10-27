#!/bin/bash

DIRNAME=$(dirname "$0")
notify() { osascript -e 'display notification "'"$1"'" with title "'"Start Apps"'"'; }

notify 'Starting apps...'

for APP in \
'Übersicht' \
'Firefox' \
'Chrome' \
'Microsoft Outlook' \
'Microsoft Teams' \
'Slack' \
; do
    if ! pgrep -f "$APP.app" &>/dev/null; then
        notify "Starting $APP"
        open -a "$APP"
    fi
done
