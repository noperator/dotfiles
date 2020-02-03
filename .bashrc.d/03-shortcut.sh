#!/bin/bash

alias cds="cd $HOME/.ssh"
alias cdf="cd $HOME/dotfiles"
alias cdg="cd $HOME/guides"
alias cdl="cd $HOME/Downloads"
alias ltd="lt $HOME/Downloads | tail"
alias cdt='cd /tmp'
alias ltt="lt /tmp/"
alias cdbd="cd $HOME/.bashrc.d"

case "$OSTYPE" in
    'darwin'*)
        alias cdw="cd $HOME/Library/Application\ Support/Übersicht/widgets"
        ;;
    'linux-gnu'*)
        DROPBOX="$HOME/Dropbox"
        NOTES="$DROPBOX/Notes"
        alias cdb="cd $DROPBOX"
        alias cdn="cd $DROPBOX/Notes"
        alias cdi3b="cd $HOME/.config/i3blocks"
        ;;
esac
