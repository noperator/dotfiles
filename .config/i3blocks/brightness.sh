#!/usr/bin/env bash

source "$HOME/.config/i3blocks/colors.sh"

BRIGHTNESS=$(xbacklight -get | sed 's/\..*//')

echo "☀ $BRIGHTNESS%"
echo "☀ $BRIGHTNESS%"
echo
