#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"

REM=$(head -n 1 /var/tmp/blocks/termdown.txt 2>/dev/null)
if [[ -n "$REM" ]]; then
    print_fa_icon 'hourglass'
    echo "$REM"
fi
