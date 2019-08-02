#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"
source "$HOME/.config/i3blocks/network.sh"

if [[ "$VPN_ENABLED" = 'true' ]]; then
  echo '🔒'
  echo '🔒'
  echo "$GREEN"
else
  echo '🌎'
  echo '🌎'
  if [[ "$ROUTE_EXISTS" = 'true' ]]; then
    echo
  else
    echo "$BLACK"
  fi
fi
