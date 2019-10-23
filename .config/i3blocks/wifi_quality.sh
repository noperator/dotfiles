#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"
source "$HOME/.config/i3blocks/network.sh"

[[ "$WIFI_ENABLED" = 'false' ]] && exit

QUALITY=$(grep "$WIFI_IF" /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')

echo "${QUALITY}%"
echo "${QUALITY}%"

# if [[ "$QUALITY" -le 40 ]]; then
#     echo "$BLACK"
if [[ "$QUALITY" -le 40 ]]; then
    echo "$RED"
elif [[ "$QUALITY" -le 60 ]]; then
    echo "$YELLOW"
else
    echo
fi
