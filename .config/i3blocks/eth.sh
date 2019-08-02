#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"
source "$HOME/.config/i3blocks/network.sh"

echo '🌍'
echo '🌍'
if [[ "$ETH_ENABLED" = 'true' ]]; then
    echo
else
    echo "$BLACK"
fi
