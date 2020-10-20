#!/usr/bin/env bash

source "$(dirname $0)/_network.sh"

if [[ "$WIFI_CONNECTED" = 'true' ]]; then
  IPADDR=$(ip addr show "$WIFI_IF" | perl -n -e "/inet ([^\/]+).* scope global/ && print \$1 and exit")
  SSID=$(iw dev wlp4s0 link | awk '/SSID:/ {print $2}')
  echo "$IPADDR $SSID"
  echo "$IPADDR $SSID"
else
  echo ' '
  echo ' '
fi

echo 
