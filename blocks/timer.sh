#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/.env"
REM=$(head -n 1 "$BLOCKS_DIR/termdown.txt" 2>/dev/null)
if [[ -n "$REM" ]]; then
    print_fa_icon 'hourglass'
    echo "$REM"
fi
