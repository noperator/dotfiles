#!/bin/bash

refresh-status() {
    osascript \
        -e 'tell application id "tracesOf.Uebersicht"' \
        -e 'set status_widgets to id of every widget whose id starts with "status"' \
        -e 'repeat with w in status_widgets' \
        -e 'refresh widget id w' \
        -e 'end repeat' \
        -e 'end tell'
}

VOICE=Tessa
FILE=/var/tmp/blocks/termdown.txt

start-timer() {
    if [[ -e "$FILE" ]]; then
        say -v "$VOICE" 'timer already running'
    else
        say -v "$VOICE" "$@ timer"
        screen -S termdown -dm termdown -v "$VOICE" --no-figlet -o "$FILE" $@
        refresh-status
    fi
}

stop-timer() {
    say -v "$VOICE" "Stopping timer"
    screen -X -S termdown quit
    rm "$FILE" 2>/dev/null
    refresh-status
}
