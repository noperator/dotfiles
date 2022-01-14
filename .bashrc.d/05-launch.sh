#!/bin/bash

case "$OSTYPE" in
'darwin'*) ;;

'linux-gnu'*)
    av() { # Audio/video
        pgrep pavucontrol || pavucontrol &
        # pgrep obs-studio || obs-studio --startvirtualcam &
        pgrep noisetorch || noisetorch &
        pgrep blueman-manager || blueman-manager &
    }
    kav() { # Kill audio/video
        for PROC in pavucontrol obs-studio noisetorch blueman-manager; do
            $(which pkill) -9 -fi "$PROC"
        done
        # i3-msg 'workspace 10:a/v; append_layout ~/.config/i3/workspace-av.json'
    }
    teams() { gco -d "$HOME/.config/chrome-Work" -a 'https://teams.microsoft.com'; }
    outlook() { gco -d "$HOME/.config/chrome-Work" -a 'https://outlook.office.com'; }
    slack() { gco -d "$HOME/.config/chrome-Work" -a 'https://app.slack.com/client'; }
    # gcal() { gco -d "$HOME/.config/chrome-Home" -a 'https://calendar.google.com'; }
    ch() { # Chat
        # pgrep slack || slack &
        xdotool search --classname 'app.slack.com__client' || slack &
        xdotool search --classname 'outlook.office.com' || outlook &
        xdotool search --classname 'teams.microsoft.com' || teams &
        pgrep thunderbird || thunderbird &
        # xdotool search --classname 'calendar.google.com' || gcal &
    }
    kch() { # Kill chat
        for PROC in teams slack; do
            $(which pkill) -9 -fi "$PROC"
        done
    }
    br() { # Browsers
        for PROFILE in Work Home; do
            DATA_DIR="$HOME/.config/chrome-$PROFILE"
            xdotool search --classname "google-chrome \($DATA_DIR\)" || gco -d "$DATA_DIR"
        done
    }
    sec() {
        pgrep opensnitch-ui || opensnitch-ui &
    }

    # Launch all apps.
    work() {
        br
        av
        ch
        sec
    }
    ;;
esac
