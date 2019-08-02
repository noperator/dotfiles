#!/usr/bin/env bash

source "$HOME/.config/i3blocks/network.sh"

if [[ "$ROUTE_EXISTS" = 'true' ]]; then
    IP=$(curl -s 'https://api.ipify.org')
    JSON=$(curl -s "https://ipapi.co/$IP/json")
    GEO=$(echo "$JSON" | jq -r '.city, .region_code, .country' | paste -sd '\ ' -)
    echo "$JSON" | jq -r '.latitude, .longitude' | paste -sd ':' - > "$HOME/.config/i3blocks/coord.txt"
    echo "$GEO $IP"
    echo "$GEO $IP"
else
    echo ' '
    echo ' '
fi
echo
