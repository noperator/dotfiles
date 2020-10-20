#!/bin/bash

source "$(dirname $0)/_fa-icons.sh"

BRIGHTNESS=$(xbacklight -get | sed 's/\..*//')

print_fa_icon 'adjust'
echo "$BRIGHTNESS%"
