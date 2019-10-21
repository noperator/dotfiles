#!/bin/bash

alias de='date "+%s"'
alias ec='exiftool -overwrite_original_in_place -all=""'
alias errcho='>&2 echo'
alias et="TERM=linux $(which et)"
alias l='clear'
alias less='less -i'
alias no='>/dev/null 2>&1'
alias vd='vimdiff'
alias vr='vim -R'
alias g='grep -iE --color'
alias vg='g -v'
gr() { g -r "$@" . | sed 's/:/ : /' | g "$@"; }
sudo() { errcho "${red}[sudo] $@${end}"; "$(which sudo)" "$@"; }
wl() { which "$@" && ls -l $(which "$@"); }

if [[ "$OSTYPE" == 'darwin'* ]]; then
    alias find='gfind'
    alias nwn='pkill brownnoise'
    alias pc='pbcopy'
    alias q='no qlmanage -p'
    alias rc='launchctl stop homebrew.mxcl.chunkwm'
    alias ssh="TERM=linux $(which ssh)"
    alias tp='open -a Typora'
    alias wn='osascript -e "set Volume 2"; (no play -n synth brownnoise &)'
fi
