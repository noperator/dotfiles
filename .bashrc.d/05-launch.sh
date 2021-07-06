#!/bin/bash

case "$OSTYPE" in
    'darwin'*)
        ;;
    'linux-gnu'*)
        av() {  # Audio/video
            pgrep pavucontrol     || pavucontrol &
            # pgrep obs-studio      || obs-studio --startvirtualcam &
            pgrep noisetorch      || noisetorch &
            pgrep blueman-manager || blueman-manager &
        }
        kav() {
            for PROC in pavucontrol obs-studio noisetorch blueman-manager; do
                $(which pkill) -9 -fi "$PROC"
            done
            # i3-msg 'workspace 10:a/v; append_layout ~/.config/i3/workspace-av.json'
        }
        teams() { gco -d "$HOME/.config/chrome-Work" -a 'https://teams.microsoft.com'; }
        outlook() { gco -d "$HOME/.config/chrome-Work" -a 'https://outlook.office.com'; }
        ch() {  # Chat
            pgrep slack    || slack &
            pgrep -f teams || teams &
        }
        kch() {
            for PROC in teams slack; do
                $(which pkill) -9 -fi "$PROC"
            done
        }
        br() {
            for PROFILE in Work Personal; do
                gco -d "$HOME/.config/chrome-$PROFILE"
            done
        }

        # Launch all apps.
        work() {
            av
            ch
            br
        }
        ;;
esac
