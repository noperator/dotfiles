#!/usr/bin/env bash

source "$HOME/.config/i3blocks/network.sh"

if [[ "$ROUTE_EXISTS" = 'true' ]]; then
    IP=$(dig -4 +short A myip.opendns.com @resolver1.opendns.com)
    JSON=$(curl -s "https://ipapi.co/$IP/json")
    GEO=$(echo "$JSON" | jq -r '.city, .region_code, .country' | paste -sd '\ ' -)
    echo "$JSON" | jq -r '.latitude, .longitude' | paste -sd ':' - > "/tmp/coord.txt"
    echo "$IP $GEO"
    echo "$IP $GEO"
else
    echo ' '
    echo ' '
fi
echo
