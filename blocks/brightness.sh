#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"

BRIGHTNESS=$(xbacklight -get | sed 's/\..*//')

echo "☀ $BRIGHTNESS%"
