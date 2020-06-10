#!/bin/bash

DIRNAME=$(dirname "$0")

# vpn \
FIRST='true'
for SCRIPT in \
geo \
gateway \
wifi \
battery \
date \
; do \
    [[ "$FIRST" == 'true' ]] || echo -n ' | '
    "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
    FIRST='false'
done
