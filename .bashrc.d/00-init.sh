#!/bin/bash

export VISUAL='vim'
export EDITOR="$VISUAL"
export HISTCONTROL='ignoreboth'  # Shorthand for ignorespace and ignoredups.
export DIALOGRC="$HOME/.dialogrc"
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.$HOSTNAME.sock"
export TMPDIR='/tmp/'
export NPM_PACKAGES="$HOME/.npm-packages"
tabs -4  # Set tab interval.

# Prepend directories to PATH without the variable growing each time this file is sourced.
OLD_PATH=$(echo "$PATH" | tr ':' '\n' | uniq | tr '\n' ':')
CUSTOM_PATH=''
for DIR in \
"$HOME/dotfiles/bin" \
"$HOME/.local/bin" \
"$NPM_PACKAGES/bin" \
"$HOME/go/bin" \
/usr/local/go/bin \
/usr/local/Cellar/python\@3.9/3.9.0/bin \
/snap/bin \
/usr/local/opt/util-linux/sbin \
/usr/local/opt/util-linux/bin \
/usr/local/sbin \
/usr/local/bin \
/usr/sbin \
/usr/bin \
/sbin \
/bin \
; do
    OLD_PATH=$(echo "$OLD_PATH" | sed -E "s%(^|:)$DIR(:|$)%\1\2%")
    CUSTOM_PATH="$CUSTOM_PATH:$DIR"
done
export PATH=$(echo "$CUSTOM_PATH:$OLD_PATH" | sed -E 's/^:|:$//g; s/:+/:/g')

if [[ -z "$TMUX" ]]; then
    export INPUTRC="$HOME/.inputrc"
else
    export INPUTRC="$HOME/.inputrc.tmux"
fi
