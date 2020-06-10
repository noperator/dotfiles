#!/bin/bash

DIRNAME=$(dirname "$0")

# vpn \
for SCRIPT in \
geo \
gateway \
wifi \
battery \
date \
; do \
    "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
done
