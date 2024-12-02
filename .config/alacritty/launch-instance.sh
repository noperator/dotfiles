#!/bin/bash

# Spawn a new Alacritty terminal window with smart display placement based on
# cursor location and window focus.
DEST_WD="$HOME"
OPTS=''

case "$OSTYPE" in
'darwin'*)
    PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"

    # Get display info before spawning
    CURSOR_DISPLAY=$(yabai -m query --displays --display mouse | jq '.index')
    FOCUSED_WINDOW=$(yabai -m query --windows --window)
    WINDOW_DISPLAY=$(echo "$FOCUSED_WINDOW" | jq '.display')
    IS_ALACRITTY=$(echo "$FOCUSED_WINDOW" | jq '.app == "Alacritty"')
    # {
    #     echo "Cursor display: $CURSOR_DISPLAY"
    #     echo "Focused window display: $WINDOW_DISPLAY"
    #     echo "Is focused window Alacritty: $IS_ALACRITTY"
    # } >/tmp/out

    if pgrep -aq alacritty; then
        OPTS='msg create-window'
        if [[ "$IS_ALACRITTY" == "true" ]]; then
            # Get working directory from focused terminal
            DEST_WD=$(echo "$FOCUSED_WINDOW" | jq -r '.title')
            if ! [[ -d "$DEST_WD" ]]; then
                DEST_WD="$HOME"
            fi
        fi

        # Set up signal to handle the new window
        # if [[ "$CURSOR_DISPLAY" != "$WINDOW_DISPLAY" ]]; then
        #     # Cursor and window on different displays - move to cursor's display after creation
        #     yabai -m signal --add \
        #         action="yabai -m window --display $WINDOW_DISPLAY; \
        #                 yabai -m window --focus \$YABAI_WINDOW_ID; \
        #                 yabai -m window --display $CURSOR_DISPLAY; \
        #                 yabai -m signal --remove temp_move_alacritty" \
        #         app=Alacritty \
        #         event=window_created \
        #         label=temp_move_alacritty
        # else
        #     # Cursor and window on same display - just focus
        #     yabai -m signal --add \
        #         action="yabai -m window --display $WINDOW_DISPLAY; \
        #                 yabai -m window --focus \$YABAI_WINDOW_ID; \
        #                 yabai -m signal --remove temp_move_alacritty" \
        #         app=Alacritty \
        #         event=window_created \
        #         label=temp_move_alacritty
        # fi
    fi

    # if [[ "$IS_ALACRITTY" == "false" ]]; then
    yabai -m signal --add \
        action="yabai -m window --focus \$YABAI_WINDOW_ID; \
                    yabai -m window --display $CURSOR_DISPLAY; \
                    yabai -m window --focus \$YABAI_WINDOW_ID; \
                    yabai -m signal --remove temp_move_alacritty" \
        app=Alacritty \
        event=window_created \
        label=temp_move_alacritty
    # fi
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

alacritty $OPTS --working-directory "$DEST_WD"
