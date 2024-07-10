#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"

print_fa_icon 'clock'
DATE_FMT='+%a %d %b %H%M'

# Local time.
date "$DATE_FMT" | tr -d '\n'

# Other time.
# export TZ='America/New_York'
# date "$DATE_FMT" | awk '{printf "/ " $NF}'
