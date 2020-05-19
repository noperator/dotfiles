#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    fp()
    {
        # Prevent error message, "A copy of Firefox is already open. Only one copy of Firefox can be open at a time."
        # More info: https://apple.stackexchange.com/a/238169
        rm ~/Library/Application\ Support/Firefox/Profiles/*/.parentlock 2>/dev/null
        /Applications/Firefox.app/Contents/MacOS/firefox --no-remote -P "$@" &
    }
    fpa()
    {
        # Open Work profile first so links are automatically opened there by default.
        for PROFILE in Work Personal; do
            fp "$PROFILE"
            while ! [[ $(pgrep -fl "firefox.*-P $PROFILE") ]]; do
                sleep 1
            done
        done
    }
fi
