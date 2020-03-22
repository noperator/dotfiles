#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    fp() { /Applications/Firefox.app/Contents/MacOS/firefox --no-remote -P "$@" & }
fi
