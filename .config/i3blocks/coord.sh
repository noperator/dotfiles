#!/usr/bin/env bash

IP=$(curl -s 'https://api.ipify.org')
COORD=$(curl -s "https://ipapi.co/$IP/json" | jq -r '.latitude, .longitude' | paste -sd ':' -)
echo "$COORD"
