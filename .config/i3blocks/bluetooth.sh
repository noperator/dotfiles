#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"

# echo '📶'
# echo '📶'
echo ''
echo ''
# echo ''
# echo ''

if [[ `bluetoothctl show | grep Powered | awk '{print $2}'` = 'yes' ]]; then
    echo "$BLUE"
else
    echo "$BLACK"
fi
