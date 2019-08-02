#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"
source "$HOME/.config/i3blocks/meminfo.sh"

MEM=$(getmem)

echo "📚 $MEM"
echo "📚 $MEM"
if [[ "$MEM" < 1 ]]; then
    echo "$RED"
elif [[ "$MEM" < 2 ]]; then
    echo "$YELLOW"
else
    echo
fi
