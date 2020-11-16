#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    PATH="/Applications/Kitty.app/Contents/MacOS:$PATH"

    # Adapted a few changes from @yanzhang0219's script to leverage yabai
    # signals to move the new kitty window to the focused display, rather than
    # the display the first kitty window was launched from.
    # - https://github.com/koekeishiya/yabai/issues/413#issuecomment-604072616
    # - https://github.com/koekeishiya/yabai/wiki/Commands#automation-with-rules-and-signals
    FOCUSED_WINDOW=$(yabai -m query --windows --window)
    FOCUSED_WINDOW_DISPLAY=$(<<< "$FOCUSED_WINDOW" jq '.display')
    FOCUSED_WINDOW_ID=$(<<< "$FOCUSED_WINDOW" jq '.id')
    yabai -m signal --add \
        action="yabai -m signal --remove temp_move_kitty;
                YABAI_WINDOW_DISPLAY=\$(yabai -m query --windows --window $YABAI_WINDOW_ID | jq '.display');
                if ! [[ \$YABAI_WINDOW_DISPLAY == $FOCUSED_WINDOW_DISPLAY ]]; then
                    yabai -m window \$YABAI_WINDOW_ID --warp $FOCUSED_WINDOW_ID;
                    yabai -m window --focus \$YABAI_WINDOW_ID;
                fi" \
        app=kitty \
        event=window_created \
        label=temp_move_kitty
fi

# If kitty is already running, open a new OS window under the same instance.
# Otherwise, start kitty. Note: on macOS, even when all kitty windows are
# closed, the main kitty process is still running.
if [[ "$OSTYPE" == 'linux-gnu'* ]] && pgrep kitty &>/dev/null; then
    kitty @ --to unix:/tmp/kitty-sock launch --type os-window --cwd current
elif [[ "$OSTYPE" == 'darwin'* ]] && [[ $(yabai -m query --windows | jq  '[.[] | select(.app == "kitty")] | length') -gt '0' ]]; then
    kitty @ --to unix:/tmp/kitty-sock launch --type os-window --cwd current
else
    kitty --listen-on unix:/tmp/kitty-sock --single-instance --directory "$HOME"
fi
