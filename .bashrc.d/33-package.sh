#!/bin/bash

case "$OSTYPE" in
    'darwin'*)
        alias bs='brew search'
        alias bi='brew install'
        alias bci='brew cask install'
        alias bsl='brew services list'
        alias bsr='brew services restart'
        ;;
    'linux-gnu'*)

        # pacman
        alias pss='pacman -Ss'
        alias pi='sudo pacman -S'
        lip ()
        {
            for PACKAGE in $(pacman -Qqe); do
                grep "\[ALPM\] installed $PACKAGE" /var/log/pacman.log
            done | sort | uniq | sed 's/\[ALPM\] installed //'
        }

        # Auracle
        alias aurs='auracle --sort=votes search'
        auri() {
            auracle info "${1#aur/}"
        }
        alias aurc='auracle clone'

        # apt
        alias apts='apt search'
        alias aptsb='apts -t buster-backports'
        alias apti='sudo apt install -y'
        alias aptib='apti -t buster-backports'
        alias aptr='sudo apt remove -y'
        alias aptu='sudo apt update'
        alias aptg='sudo apt upgrade'
        alias aptli='apt list --installed'
        alias aptlu='apt list --upgradable'

        ;;
esac
