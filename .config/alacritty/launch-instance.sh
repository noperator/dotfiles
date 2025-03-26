#!/bin/bash
# Spawn a new Alacritty terminal window with smart display placement based on
# cursor location and window focus.
DEST_WD="$HOME"
OPTS=''
SSH_CMD=''

FORCE_LOCAL='false'
if [[ "$1" == 'local' ]]; then
    FORCE_LOCAL='true'
fi

parse_ssh_title() {
    local title="$1"
    # Match format "user@host:dir"
    if [[ "$title" =~ ^([^@]+)@([^:]+):(.+)$ ]]; then
        local user="${BASH_REMATCH[1]}"
        local host="${BASH_REMATCH[2]}"
        local dir="${BASH_REMATCH[3]}"

        # Look for matching control socket
        local socket_path=$(find ~/.ssh/sockets -type s -name "*${user}@${host}*" -print -quit 2>/dev/null)
        if [[ -n "$socket_path" ]]; then
            # Return the ssh command that will connect and cd to the right directory
            echo "ssh -t -S '$socket_path' dummy 'cd $dir && \$SHELL'"
            return 0
        fi
    fi
    return 1
}

case "$OSTYPE" in
'darwin'*)
    PATH="/Applications/Alacritty.app/Contents/MacOS/:$PATH"
    # Get display info before spawning
    CURSOR_DISPLAY=$(yabai -m query --displays --display mouse | jq '.index')
    FOCUSED_WINDOW=$(yabai -m query --windows --window)
    WINDOW_DISPLAY=$(echo "$FOCUSED_WINDOW" | jq '.display')
    IS_ALACRITTY=$(echo "$FOCUSED_WINDOW" | jq '.app == "Alacritty"')

    if pgrep -aq alacritty; then
        OPTS='msg create-window'
        if [[ "$IS_ALACRITTY" == "true" ]]; then
            WINDOW_TITLE=$(echo "$FOCUSED_WINDOW" | jq -r '.title')

            # Try to parse as SSH session first
            SSH_CMD=$(parse_ssh_title "$WINDOW_TITLE")
            # if [[ $? -eq 0 ]] && [[ "$FORCE_LOCAL" == 'false' ]]; then
            if [[ $? -eq 0 ]]; then
                # SSH command set, we'll use it later
                DEST_WD="$HOME" # Directory doesn't matter for SSH sessions
            else
                # Not SSH, treat as local directory
                if [[ -d "$WINDOW_TITLE" ]]; then
                    DEST_WD="$WINDOW_TITLE"
                else
                    DEST_WD="$HOME"
                fi
            fi
        fi
    fi

    yabai -m signal --add \
        action="yabai -m window --focus \$YABAI_WINDOW_ID; \
                yabai -m window --display $CURSOR_DISPLAY; \
                yabai -m window --focus \$YABAI_WINDOW_ID; \
                yabai -m signal --remove temp_move_alacritty" \
        app=Alacritty \
        event=window_created \
        label=temp_move_alacritty
    ;;

'linux-gnu'*)
    PATH="$HOME/.cargo/bin:$PATH"
    ACTIVE_WIN_ID=$(xprop -root *NET*ACTIVE_WINDOW | awk '{print $NF}')
    ACTIVE_WIN_CLASS=$(xprop -id "$ACTIVE_WIN_ID" WM_CLASS | awk '{gsub(/"/, "", $NF); print $NF}')
    if [[ "$ACTIVE_WIN_CLASS" == 'Alacritty' ]]; then
        TERM_PID=$(xprop -id "$ACTIVE_WIN_ID" *NET*WM_PID | awk '{print $NF}')
        SHELL_PID=$(pgrep -P "$TERM_PID" ${SHELL##*/})
        DEST_WD=$(readlink -e "/proc/$SHELL_PID/cwd")
    fi
    ;;
esac

if [[ "$FORCE_LOCAL" == 'false' ]] && [[ -n "$SSH_CMD" ]]; then
    # Launch with SSH command if we detected an SSH session
    alacritty $OPTS --command bash -c "$SSH_CMD"
else
    # Otherwise just use the working directory
    alacritty $OPTS --working-directory "$DEST_WD"
fi
