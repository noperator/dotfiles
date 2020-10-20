#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"
source "$(dirname $0)/_network.sh"

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
