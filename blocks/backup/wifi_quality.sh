#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"
source "$(dirname $0)/_network.sh"

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
