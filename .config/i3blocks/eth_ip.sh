#!/usr/bin/env bash

source "$HOME/.config/i3blocks/network.sh"

if [[ "$ETH_ENABLED" = 'true' ]]; then
  IPADDR=$(ip addr show "$ETH_IF" | perl -n -e "/inet ([^\/]+).* scope global/ && print \$1 and exit")
  if [[ -z "$IPADDR" ]]; then
    echo " "
    echo " "
  else
    echo "$IPADDR"
    echo "$IPADDR"
  fi
else
  echo " "
  echo " "
fi

echo 
