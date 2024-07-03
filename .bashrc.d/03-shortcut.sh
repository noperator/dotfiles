#!/bin/bash

DROPBOX="$HOME/Dropbox"
alias cdb="cd $DROPBOX"
alias cds="cd $HOME/.ssh"
alias cdv="cd $HOME/.vim"
alias cdf="cd $HOME/dotfiles"
alias cdg="cd $HOME/guides"
alias cdl="cd $HOME/Downloads"
alias cde="cd $HOME/Desktop"
alias ltd="lt --color=always $HOME/Downloads | tail"
alias cdt='cd /tmp'
alias ltt='lt /tmp/'
alias cdu="cd $HOME/tmp"
alias ltu="lt $HOME/tmp"
alias cdbd="cd $HOME/dotfiles/.bashrc.d"
alias cdbl="cd $HOME/dotfiles/blocks"
alias cdco="cd $HOME/.config"
alias cdsc="cd $HOME/screenshots"
alias cdvt='cd /var/tmp'
alias mb='mv'

case "$OSTYPE" in
'darwin'*)
    alias cdw="cd $HOME/Library/Application\ Support/Übersicht/widgets"
    ;;
'linux-gnu'*)
    NOTES="$DROPBOX/Notes"
    alias cdn="cd $DROPBOX/Notes"
    alias cdi3b="cd $HOME/.config/i3blocks"
    ;;
esac
