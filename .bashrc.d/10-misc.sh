#!/bin/bash

alias smile='<<< '🙂' pbcopy'
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
alias sus='sort | uniq -c | sort -n'
alias sba='source env/bin/activate'
alias hd='hexdump -C'
alias xlf='xmllint --format'
alias vbe="vim $HOME/.bashrc.extra"
rename_screen_cap() {
    NAME="$1"
    EXT="$2"
    TYPE="$3"
    DIR="$HOME/Desktop"
    RENAME="$DIR/$NAME.$EXT"
    SCREENCAP=$(find "$DIR" -name "Screen $TYPE*.$EXT" | sort -n | tail -n 1)
    if [[ -f "$RENAME" ]]; then
        echo "$RENAME already exists!"
    else
        ec "$SCREENCAP"
        mv "$SCREENCAP" "$RENAME"
        echo "Original: $SCREENCAP"
        echo "Renamed:  $RENAME"
        no qlmanage -p "$RENAME"
    fi
}
mvss() {
    rename_screen_cap "$1" 'png' 'Shot'
}
mvsr() {
    rename_screen_cap "$1" 'mov' 'Recording'
}
sudo() { errcho -e "${CLR[RED]}[sudo] $@${CLR[END]}"; "$(which sudo)" "$@"; }
wl() { which "$@" && ls -l $(which "$@"); }
alias csc="cat $HOME/.ssh/config"
skg () { ssh-keygen -t rsa -b 4096 -o -a 100 -q -N '' -f "$HOME/.ssh/$1"; }

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
        alias tp='typora'
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
