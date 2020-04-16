#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    fp()
    {
        rm ~/Library/Application\ Support/Firefox/Profiles/*/.parentlock
        /Applications/Firefox.app/Contents/MacOS/firefox --no-remote -P "$@" &
    }
    alias fpa='for PROFILE in Work Personal; do fp "$PROFILE"; sleep 1; done'
fi
