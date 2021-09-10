#!/bin/bash

# Spawn a new Alacritty terminal window. If the active (i.e., focused) window
# is a Alacritty terminal window, find the current working directory of its
# corresponding attached shell, and spawn a new terminal window in the same
# working directory. Otherwise, spawn the shell in the home directory.
ACTIVE_WIN_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $NF}')
ACTIVE_WIN_CLASS=$(xprop -id "$ACTIVE_WIN_ID" WM_CLASS | awk '{gsub(/"/, "", $NF); print $NF}')
if [[ "$ACTIVE_WIN_CLASS" == 'Alacritty' ]]; then
    TERM_PID=$(xprop -id "$ACTIVE_WIN_ID" _NET_WM_PID | awk '{print $NF}')
    SHELL_PID=$(pgrep -P "$TERM_PID" ${SHELL##*/})
    DEST_WD=$(readlink -e "/proc/$SHELL_PID/cwd")
else
    DEST_WD="$HOME"
fi

PATH="$HOME/.cargo/bin:$PATH"
alacritty --working-directory "$DEST_WD"
