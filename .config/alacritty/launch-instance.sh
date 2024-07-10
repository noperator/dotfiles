#!/bin/bash

# Spawn a new Alacritty terminal window. If the active (i.e., focused) window
# is a Alacritty terminal window, find the current working directory of its
# corresponding attached shell, and spawn a new terminal window in the same
# working directory. Otherwise, spawn the shell in the home directory.
DEST_WD="$HOME"
OPTS=''
case "$OSTYPE" in
'darwin'*)
    PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"
    yabai -m signal --add \
        action="yabai -m signal --remove temp_move_alacritty;
                yabai -m window --focus \$YABAI_WINDOW_ID;" \
        app=Alacritty \
        event=window_created \
        label=temp_move_alacritty
    if pgrep -aq alacritty; then
        OPTS='msg create-window'
        TERM_PID=$(yabai -m query --windows | jq '.[] | select(.["has-focus"] == true and .app == "Alacritty") | .pid')
        # SHELL_INDEX=$(yabai -m query --windows | jq 'map(select(.app == "Alacritty") | {id, "has-focus"}) | sort_by(.id) | to_entries[] | select(.value | .["has-focus"] == true) | .key')
        if [[ -n "$TERM_PID" ]]; then
            # SHELL_PID=$(pgrep -aP "$TERM_PID" sh | sort -n | sed "$(($SHELL_INDEX + 1))q;d")
            # DEST_WD=$(lsof -a -p "$SHELL_PID" -d cwd -F n | tail -n 1 | sed -E 's/^.//')
            DEST_WD=$(yabai -m query --windows | jq -r '.[] | select(.["has-focus"] == true and .app == "Alacritty") | .title')
            if ! [[ -d "$DEST_WD" ]]; then
                DEST_WD="$HOME"
            fi
        fi
    fi
    ;;
'linux-gnu'*)
    PATH="$HOME/.cargo/bin:$PATH"
    ACTIVE_WIN_ID=$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $NF}')
    ACTIVE_WIN_CLASS=$(xprop -id "$ACTIVE_WIN_ID" WM_CLASS | awk '{gsub(/"/, "", $NF); print $NF}')
    if [[ "$ACTIVE_WIN_CLASS" == 'Alacritty' ]]; then
        TERM_PID=$(xprop -id "$ACTIVE_WIN_ID" _NET_WM_PID | awk '{print $NF}')
        SHELL_PID=$(pgrep -P "$TERM_PID" ${SHELL##*/})
        DEST_WD=$(readlink -e "/proc/$SHELL_PID/cwd")
    fi
    ;;
esac

# echo "term:  $TERM_PID"
# echo "shell: $SHELL_PID"
# echo "wd:    $DEST_WD"
# OPTS="$OPTS --working-directory $DEST_WD"
echo "$OPTS"
alacritty $OPTS --working-directory "$DEST_WD"
