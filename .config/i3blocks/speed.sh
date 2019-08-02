#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"
source "$HOME/.config/i3blocks/network.sh"

RESULTS=$(speedtest-cli --single --simple --bytes)

UPLOAD=$(echo "$RESULTS" | awk '$1 == "Upload:" {print $2}')
DOWNLOAD=$(echo "$RESULTS" | awk '$1 == "Download:" {print $2}')

echo "↑ ${UPLOAD}M ↓ ${DOWNLOAD}M"
echo "↑ ${UPLOAD}M ↓ ${DOWNLOAD}M"
echo

