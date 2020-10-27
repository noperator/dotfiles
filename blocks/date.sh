#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"

print_fa_icon 'clock'
date '+%a %d %b %H%M' | tr '\n' ' '
echo
