#!/usr/bin/env bash

source "$HOME/.config/i3blocks/network.sh"

if [[ "$WIFI_CONNECTED" = 'true' ]]; then
  IPADDR=$(ip addr show "$WIFI_IF" | perl -n -e "/inet ([^\/]+).* scope global/ && print \$1 and exit")
  SSID=$(iwgetid "$WIFI_IF" --raw)
  echo "$SSID $IPADDR"
  echo "$SSID $IPADDR"
else
  echo ' '
  echo ' '
fi

echo 
