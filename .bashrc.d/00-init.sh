#!/bin/bash

# export KERNEL_RELEASE="$(uname -r)"  # $OSTYPE should suffice instead.
# export TERMINAL='urxvt'  # Not sure why I needed this.
export VISUAL='vim'
export EDITOR="$VISUAL"
export HISTCONTROL='ignoreboth'  # Shorthand for ignorespace and ignoredups.
export DIALOGRC="$HOME/.dialogrc"
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.$HOSTNAME.sock"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
export PATH="$HOME/dotfiles/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

if [[ -z "$TMUX" ]]; then
    export INPUTRC="$HOME/.inputrc"
else
    export INPUTRC="$HOME/.inputrc.tmux"
fi
