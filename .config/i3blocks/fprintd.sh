#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"

echo '🔑'
echo '🔑'

if [[ `/usr/bin/pgrep fprintd` ]]; then
    echo "$GREEN"
else
    echo "$BLACK"
fi
