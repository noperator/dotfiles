#!/bin/bash

SCREENSHOT="$HOME/screenshots/$(date --iso=ns | sed -E 's/-[^-]*$//; s/,/./; s/:/-/g').png"
import "$SCREENSHOT" &&
    notify-send "Screenshot" "$SCREENSHOT" &&
    xclip <<<"$SCREENSHOT"
