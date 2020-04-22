#!/bin/bash

link() { ln -s "$HOME/dotfiles/$1" "$HOME/$2"; }

for FILE in \
.bash_profile \
.bashrc \
.bashrc.d \
.config \
.hushlogin \
.inputrc \
.inputrc.tmux \
.tmux.conf \
.vimrc \
; do
    link "$FILE"
done

case "$OSTYPE" in
    'linux-gnu'*)
        for FILE in \
        .asoundrc \
        .local \
        .xinitrc \
        .Xresources \
        ; do
            link "$FILE"
        done
        ;;
    'darwin'*)
        link .skhdrc.yabai .skhdrc
        link .yabairc
        link widgets 'Library/Application Support/Übersicht/'
        find terminal -type f | while read FILE; do
            link "$FILE"
        done
        for PROFILE in $(ls "$HOME/Library/Application Support/Firefox/Profiles/"); do
            link user.js "Library/Application Support/Firefox/Profiles/$PROFILE"
        done
        ;;
esac
