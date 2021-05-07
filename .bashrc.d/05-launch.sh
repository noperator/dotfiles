#!/bin/bash

case "$OSTYPE" in
    'darwin'*)
        ;;
    'linux-gnu'*)
        av() {  # Audio/video
            pgrep pavucontrol     || pavucontrol &
            pgrep obs-studio      || obs-studio --startvirtualcam &
            pgrep noisetorch      || noisetorch &
            pgrep blueman-manager || blueman-manager &
        }
        kav() {
            for PROC in pavucontrol obs-studio noisetorch blueman-manager; do
                $(which pkill) -9 -fi "$PROC"
            done
        }
        ch() {  # Chat
            for PROC in teams-for-linux slack; do
                pgrep "$PROC" || "$PROC" &
            done
        }
        kch() {
            for PROC in teams-for-linux slack; do
                $(which pkill) -9 -fi "$PROC"
            done
        }
        ;;
esac
