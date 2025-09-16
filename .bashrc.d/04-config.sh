#!/bin/bash

alias sb="source $HOME/.bash_profile"
alias vb="vim $HOME/.bashrc"
alias vbh="vim $HOME/.bash_history"
alias vsc="vim $HOME/.ssh/config"
alias vv="vim $HOME/.vimrc"
alias vnv="vim $HOME/.config/nvim/init.vim"
alias vk="vim $HOME/.config/kitty/kitty.conf"
alias vf="vim $HOME/.finicky.js"
alias va="vim $HOME/.config/alacritty/alacritty.toml"
tbh() { tail -n $(if [[ -z "$1" ]]; then echo 10; else echo "$1"; fi) "$HOME/.bash_history"; }
gbh() { grep -iE --color "$@" "$HOME/.bash_history"; }
gbr() { grep -iE --color "$@" "$HOME/.bashrc"; }

case "$OSTYPE" in
'darwin'*)
    alias vc="vim $HOME/.chunkwmrc"
    alias vy="vim $HOME/.yabairc"
    alias vs="vim $HOME/.skhdrc"
    ;;
'linux-gnu'*)
    alias van="vim $DROPBOX/Code/guides/arch_notes.txt"
    alias vi3="vim $HOME/.config/i3/config"
    alias vi3b="vim $HOME/.config/i3blocks/config"
    alias vx="vim $HOME/.Xresources"
    ;;
esac
