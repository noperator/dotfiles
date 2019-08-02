#!/usr/bin/env bash

DEST_WD="$HOME"
ACTIVE_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $NF}')
ACTIVE_TITLE=$(xprop -id "$ACTIVE_ID" WM_COMMAND)
if [[ "$ACTIVE_TITLE" = *"$TERMINAL"* ]]; then
  ACTIVE_PID=$(xprop -id "$ACTIVE_ID" _NET_WM_PID | awk '{print $NF}')
  DEST_WD=$(readlink -e /proc/`pgrep --parent "$ACTIVE_PID" ${SHELL##*/}`/cwd)
fi
urxvt -cd "$DEST_WD"
