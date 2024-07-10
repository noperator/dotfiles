#!/bin/bash

DIRNAME=$(dirname "$0")
notify() { osascript -e 'display notification "'"$1"'" with title "'"Start Apps"'"'; }
source "$DIRNAME/../.bashrc.d/37-browser.sh"

notify 'Starting apps...'

# 'Google Chrome' \
# 'Firefox' \
for APP in \
    'Übersicht' \
    'Microsoft Outlook' \
    'Microsoft Teams' \
    'Slack'; do
    if ! pgrep -f "$APP.app" &>/dev/null; then
        notify "Starting $APP"
        open -a "$APP"
    fi
done

# Start browsers; see also ../.bashrc.d/05-launch.sh.
for PROFILE in Work Home; do
    DATA_DIR="$HOME/.config/chrome-$PROFILE"
    if ! pgrep -if "chrom.*$DATA_DIR" 2>/dev/null; then
        notify "Starting Chrome ($PROFILE)"
        gco -d "$DATA_DIR"
    fi
done
