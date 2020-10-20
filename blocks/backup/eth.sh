#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"
source "$(dirname $0)/_network.sh"

echo '🌍'
echo '🌍'
if [[ "$ETH_ENABLED" = 'true' ]]; then
    echo
else
    echo "$BLACK"
fi
