#!/bin/bash

export VISUAL='vim'
export EDITOR="$VISUAL"
export SYSTEMD_EDITOR="$VISUAL"
export HISTCONTROL='ignorespace'
export DIALOGRC="$HOME/.dialogrc"
# export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.$HOSTNAME.sock"
export TMPDIR='/tmp/'
export NPM_PACKAGES="$HOME/.npm-packages"
export TIMEFORMAT='%3lR' # Only show elapsed time.
# tabs -4                  # Set tab interval.
export GPG_TTY=$(tty)

# Homebrew stuff.
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
# export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:";
# export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}";

# Prepend directories to PATH without the variable growing each time this file is sourced.
OLD_PATH=$(echo "$PATH" | tr ':' '\n' | uniq | tr '\n' ':')
CUSTOM_PATH=''
for DIR in \
    "$HOME/dotfiles/bin" \
    "$HOME/.local/bin" \
    "$HOME/go/bin" \
    "$HOME/.cargo/bin" \
    "$NPM_PACKAGES/bin" \
    "$HOME/kitty/kitty/launcher" \
    "$HOME/.bfrtk/bin" \
    "$HOME/.codeium/windsurf/bin" \
    /usr/local/texlive/2024/bin/universal-darwin/ \
    /usr/local/go/bin \
    /usr/local/Cellar/python\@3.9/3.9.0/bin \
    /usr/local/Cellar/python\@3.9/3.9.2_1/bin \
    /usr/local/Cellar/python\@3.8/3.8.8_1/bin \
    /opt/homebrew/opt/node@20/bin \
    "$HOMEBREW_PREFIX/bin" \
    "$HOMEBREW_PREFIX/sbin" \
    "$HOMEBREW_PREFIX/opt/util-linux/bin" \
    "$HOMEBREW_PREFIX/opt/util-linux/sbin" \
    /opt/local/sbin \
    /opt/local/bin \
    /snap/bin \
    /usr/local/sbin \
    /usr/local/bin \
    /usr/sbin \
    /usr/bin \
    /sbin \
    /bin; do
    OLD_PATH=$(echo "$OLD_PATH" | sed -E "s%(^|:)$DIR(:|$)%\1\2%")
    CUSTOM_PATH="$CUSTOM_PATH:$DIR"
done
export PATH=$(echo "$CUSTOM_PATH:$OLD_PATH" | sed -E 's/^:|:$//g; s/:+/:/g')

# Same for LD_LIBRARY_PATH.
OLD_LD_LIBRARY_PATH=$(echo "$LD_LIBRARY_PATH" | tr ':' '\n' | uniq | tr '\n' ':')
CUSTOM_LD_LIBRARY_PATH=''
for DIR in \
    '/usr/local/lib'; do
    OLD_LD_LIBRARY_PATH=$(echo "$OLD_LD_LIBRARY_PATH" | sed -E "s%(^|:)$DIR(:|$)%\1\2%")
    CUSTOM_LD_LIBRARY_PATH="$CUSTOM_LD_LIBRARY_PATH:$DIR"
done
export LD_LIBRARY_PATH=$(echo "$CUSTOM_LD_LIBRARY_PATH:$OLD_LD_LIBRARY_PATH" | sed -E 's/^:|:$//g; s/:+/:/g')

if [[ -z "$TMUX" ]]; then
    export INPUTRC="$HOME/.inputrc"
else
    export INPUTRC="$HOME/.inputrc.tmux"
fi
