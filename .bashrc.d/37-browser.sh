#!/bin/bash

case "$OSTYPE" in
    'linux-gnu'*)
        alias chrome='google-chrome-stable --disable-gpu'
        ;;
    'darwin'*)
        fp()   # Firefox profile.
        {
            # Prevent error message, "A copy of Firefox is already open. Only one
            # copy of Firefox can be open at a time." More info:
            # - https://apple.stackexchange.com/a/238169
            if ! pgrep -f "firefox.*-P $1" >/dev/null; then
                rm "$HOME/Library/Application Support/Firefox/Profiles/"*"/.parentlock" 2>/dev/null
                /Applications/Firefox.app/Contents/MacOS/firefox --no-remote -P "$1" &
            else
                echo "Firefox already running with profile $1"
            fi
        }
        fpa()  # Firefox profile _all_.
        {
            # Open Work profile first so that links are automatically opened there
            # by default.
            for PROFILE in Work Personal; do
                fp "$PROFILE"
                while ! [[ $(pgrep -fl "firefox.*-P $PROFILE") ]]; do
                    sleep 1
                done
            done
        }
        ;;
esac
