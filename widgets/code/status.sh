#!/bin/bash

DIRNAME=$(dirname "$0")

# Check if Slack or Teams are screen sharing.
screen_sharing() {
    if [[ $(/usr/local/bin/yabai -m query --windows |
            jq -r '[.[] | select(.app      == "Slack" and
                                 .floating == 1       and
                                 .frame.w  == 400     and
                                 .frame.h  == 56)] | length') -gt 0 ]] ||
       pgrep -f '\-msteams-process-type=appSharingToolbar' &>/dev/null; then
        echo '@exclamation-triangle@ @desktop@  '
    else
        false
    fi
}

# Only display networking information if not screen sharing.
if ! screen_sharing; then
    for SCRIPT in \
    geo \
    gateway \
    wifi \
    ; do \
        "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
    done
fi

for SCRIPT in \
battery \
date \
; do \
    "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
done
