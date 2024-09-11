#!/bin/bash

DROPBOX="$HOME/Dropbox"
alias cdb="cd $DROPBOX"
alias cdco="cd $HOME/.config"
alias cds="cd $HOME/.ssh"
alias cdv="cd $HOME/.vim"
alias cde="cd $HOME/Desktop"
alias cdl="cd $HOME/Downloads"
alias cdf="cd $HOME/dotfiles"
alias cdbd="cd $HOME/dotfiles/.bashrc.d"
alias cdbl="cd $HOME/dotfiles/blocks"
alias cdg="cd $HOME/guides"
alias cdgh="cd $HOME/github"
alias cdp="cd $HOME/projects"
alias cdsc="cd $HOME/screenshots"
alias cdu="cd $HOME/tmp"
alias ltu="lt $HOME/tmp"
alias ltd="lt --color=always $HOME/Downloads | tail"
alias cdt='cd /tmp'
alias cdvt='cd /var/tmp'
alias ltt='lt /tmp/'
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
