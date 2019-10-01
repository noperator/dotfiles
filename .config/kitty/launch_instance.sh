#!/bin/bash

SPACE=$(/usr/local/bin/yabai -m query --spaces --space | jq '.index' -r)

APP=$(/usr/local/bin/yabai -m query --windows --window | jq '.app' -r)

if [[ "$APP" == 'kitty' ]]; then
    DIR=$(/Applications/Kitty.app/Contents/MacOS/kitty @ --to unix:/tmp/mykitty ls | /usr/local/bin/jq '.[] | select(.is_focused==true) | .tabs[] | select(.is_focused==true) | .windows[] | .cwd' -r)
else
    DIR="$HOME"
fi

/Applications/Kitty.app/Contents/MacOS/kitty --listen-on unix:/tmp/mykitty --single-instance --directory "$DIR"

WINDOW=$(/usr/local/bin/yabai -m query --windows --window | jq '.id' -r)

/usr/local/bin/yabai -m window --space "$SPACE"
