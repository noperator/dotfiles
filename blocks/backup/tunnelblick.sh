#!/bin/bash

VPN_DIR="$HOME/Library/Application Support/Tunnelblick/Configurations"
CONFIG_NAME=$(ls "$VPN_DIR" | sed -E 's/.tblk//g' | tail -n 1)
STATE=$(osascript -e "tell application \"/Applications/Tunnelblick.app\"" -e "get state of first configuration where name=\"$CONFIG_NAME\"" -e "end tell")

if [[ "$STATE" == 'CONNECTED' ]]; then
    echo -n '@lock@ '
    IP=$(ifconfig tap0 inet | awk '/inet/ {print $2}')
    echo -n "$IP "
else
    echo -n '@lock-open@ '
fi

echo "$CONFIG_NAME"
