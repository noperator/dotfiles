#!/bin/bash

alias de='date "+%s"'
alias ec='exiftool -overwrite_original_in_place -all=""'
alias errcho='>&2 echo'
alias et="TERM=linux $(which et 2> /dev/null)"
alias l='clear'
alias less='less -i'
alias no='>/dev/null 2>&1'
alias vd='vimdiff'
alias vr='vim -R'
alias g='grep -iE --color'
alias vg='g -v'
alias cls='printf "\033c"'
alias sudoedit="EDITOR=$EDITOR sudoedit"
gr() { g -r "$@" . | sed 's/:/ : /' | g "$@"; }
sudo() { errcho "${red}[sudo] $@${end}"; "$(which sudo)" "$@"; }
wl() { which "$@" && ls -l $(which "$@"); }
nowrap() {
    [ -t 1 ] && tput rmam
    "$@"; local ret="$?"
    [ -t 1 ] && tput smam
    return "$ret"
}
alias nowrap='nowrap '
sgu() { echo "https://git.io/$(http --form POST https://git.io/create url=$1)"; }
alias csc="cat $HOME/.ssh/config"

case "$OSTYPE" in
    'darwin'*)
        alias find='gfind'
        alias nwn='pkill brownnoise'
        alias pc='pbcopy'
        alias q='no qlmanage -p'
        alias rc='launchctl stop homebrew.mxcl.chunkwm'
        alias ssh="TERM=linux $(which ssh)"
        alias tp='open -a Typora'
        alias wn='osascript -e "set Volume 2"; (no play -n synth brownnoise &)'
        ;;
    'linux-gnu'*)
        alias z="zathura"
        alias dbs="dropbox-cli status"
        alias kq='pkill -9 qutebrowser'
        alias fb="$HOME/.fehbg"
        alias wn="nohup play -n synth brownnoise pinknoise >/dev/null 2>&1 &"
        alias nn='pkill play'
        ;;
esac

i() {
    echo "NAME: $@"
    echo -n 'SIZE: '
    case "$OSTYPE" in
        'darwin'*)
        stat -f %z "$@" | tr '\n' ' '
        ;;
        'linux-gnu'*)
        stat --printf='%s\n' "$@" | tr '\n' ' '
        ;;
    esac
    echo "($(du -h $@ | awk '{print $1}'))"
    echo -n 'TYPE: '
    file -b "$@"
    echo -n 'SHA1: '
    sha1sum "$@" | awk '{print $1}'
}
