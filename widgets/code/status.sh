#!/bin/bash

DIRNAME=$(dirname "$0")

# vpn \

if [[ ! $(pgrep -afli 'appSharingToolbar') ]]; then
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
