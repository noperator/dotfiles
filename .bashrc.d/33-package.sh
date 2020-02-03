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
        alias pss='pacman -Ss'
        alias pi='sudo pacman -S'
        alias aurs='auracle --sort=votes search'
        alias auri='auracle info'
        alias aurc='auracle clone'
        ;;
esac
