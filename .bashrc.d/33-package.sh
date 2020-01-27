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
        alias pss="pacman -Ss"
        alias pmi="sudo pacman -S"
        alias cs="cower --sort votes -c -s"
        alias ci="cower -i"
        ;;
esac
