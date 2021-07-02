#!/bin/bash

# I initially established entirely separate data directories for running two
# parallel instances (i.e., Work and Personal) of Firefox. This worked fine for
# a while, but perhaps after an update--not exactly sure what happened--the
# Firefox profiles stopped working and I lost extension/theme preferences,
# browsing history, bookmarks, etc. Since then, I've simply opted to use
# separate browsers for different purposes.
#
# Also worth noting is that Firefox would _crash_ (on macOS) anytime I tried to
# start a video call. Chrom* does fine, though.


########
# Chrom(e|ium)
####

# Find data directory by looking for Profile Path at chrome://version
# - https://www.chromium.org/developers/creating-and-using-profiles
# - https://chromium.googlesource.com/chromium/src/+/master/docs/user_data_dir.md
case "$OSTYPE" in
    'linux-gnu'*)
        # CHROME_USER_DATA_BASE="$HOME/.config/google-chrome"
        CHROME_BIN='/usr/bin/google-chrome'
        ;;
    'darwin'*)
        # CHROME_USER_DATA_BASE="$HOME/Library/Application Support/Google/Chrome"
        # CHROME_BIN='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
        # CHROME_USER_DATA_BASE="$HOME/Library/Application Support/Chromium"
        CHROME_BIN='/Applications/Chromium.app/Contents/MacOS/Chromium'
        ;;
esac

# Quickly open Chrome while specifying a user data directory, profile
# directory, proxy, and url. Note that two separate profiles under the same
# user data directory will open in the same, existing browser session. They
# follow this hierarchy: USER-DATA-DIR/PROFILE-DIR
gco()  # Google Chrome open.
{
    CHROME_USER_DATA_DIR=''
    CHROME_PROFILE_DIR=''
    CHROME_PROXY_SERVER=''
    CHROME_URL=''
    local OPTIND
    while getopts ":d:p:x:u:" opt; do
        case ${opt} in
            d )
                CHROME_USER_DATA_DIR="$OPTARG"
                ;;
            p )
                CHROME_PROFILE_DIR="$OPTARG"
                ;;
            x )
                CHROME_PROXY_SERVER="$OPTARG"
                ;;
            u )
                CHROME_URL="$OPTARG"
                ;;
            \? )
                echo "Invalid option: $OPTARG" >&2
                false
                return
                ;;
            : )
                echo "Invalid option: $OPTARG requires an argument" >&2
                false
                return
                ;;
        esac
    done
    shift $((OPTIND -1))

    CHROME_ARGS=''
    if [[ -n "$CHROME_USER_DATA_DIR" ]]; then
        # CHROME_ARGS="$CHROME_ARGS --user-data-dir='$CHROME_USER_DATA_BASE/$CHROME_USER_DATA_DIR'"
        CHROME_ARGS="$CHROME_ARGS --user-data-dir='$CHROME_USER_DATA_DIR'"
    fi
    if [[ -n "$CHROME_PROFILE_DIR" ]]; then
        CHROME_ARGS="$CHROME_ARGS --profile-directory='$CHROME_PROFILE_DIR'"
    fi
    if [[ -n "$CHROME_PROXY_SERVER" ]]; then
        CHROME_ARGS="$CHROME_ARGS --proxy-server='$CHROME_PROXY_SERVER'"
    fi
    if [[ -n "$CHROME_URL" ]]; then
        CHROME_ARGS="$CHROME_ARGS '$CHROME_URL'"
    fi

    echo "[*] Starting $(basename $CHROME_BIN) with args: $CHROME_ARGS"
    eval "$CHROME_BIN $CHROME_ARGS" &
}


if [[ "$OSTYPE" == 'darwin'* ]]; then
    ########
    # Firefox
    ####

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
else
    alias chrome='google-chrome-stable --disable-gpu &'
fi
