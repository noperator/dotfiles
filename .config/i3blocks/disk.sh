#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"

USAGE=$(df -h | grep '/dev/sda1' | awk '{print $4}')

echo "💾 $USAGE"
echo "💾 $USAGE"
echo
