#!/bin/bash

for FILE in .bash_profile .bashrc .bashrc.d .config .hushlogin .inputrc .inputrc.tmux .tmux.conf .vimrc; do
    ln -s "$HOME/dotfiles/$FILE" "$HOME/"
done

case "$OSTYPE" in
    'linux-gnu')
        for FILE in .local .xinitrc .Xresources; do
            ln -s "$HOME/dotfiles/$FILE" "$HOME/"
        done
        ;;
    # 'darwin'*)
    # .chunkwmrc
    # .skhdrc.chunkwm
    # .skhdrc.yabai
    # .yabairc
    # widgets
    # ;;
esac
