#!/bin/bash

alias vv="vim $HOME/.vimrc"
alias vb="vim $HOME/.bashrc"
alias vbp="vim $HOME/.bash_profile"
alias sb="source $HOME/.bash_profile"
alias vbh="vim $HOME/.bash_history"
tbh() { tail -n $( if [[ -z "$1" ]]; then echo 10; else echo "$1"; fi ) "$HOME/.bash_history"; }
gbh() { g "$@" "$HOME/.bash_history"; }
gbr() { g "$@" "$HOME/.bashrc"; }

if [[ "$OSTYPE" == 'darwin'* ]]; then
    alias vc="vim $HOME/.chunkwmrc"
    alias vy="vim $HOME/.yabairc"
    alias vs="vim $HOME/.skhdrc"
    alias vk="vim $HOME/.config/kitty/kitty.conf"
fi
