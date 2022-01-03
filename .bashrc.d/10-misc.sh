#!/bin/bash

which nvim &>/dev/null && alias vim='nvim'
alias smile='<<< '🙂' pbcopy'
alias de='date "+%s"'
alias ec='exiftool -overwrite_original_in_place -all=""'
alias errcho='>&2 echo'
alias et="TERM=linux $(which et 2>/dev/null)"
alias l='clear'
alias less='less -i'
alias no='>/dev/null 2>&1'
alias vd='vimdiff'
vr() {
    FILE='-'
    ! [[ -z "$1" ]] && FILE="$1"
    vim -R "$FILE"
}
alias g='grep -iE --color'
alias vg='g -v'
alias cls='printf "\033c"'
alias sudoedit="EDITOR=$EDITOR sudoedit"
alias sus='sort | uniq -c | sort -n'
alias sba='source venv/bin/activate'
alias hd='hexdump -C'
alias xlf='xmllint --format'
alias vbe="vim $HOME/.bashrc.extra"
rtc() { # Random Todoist color
    COLOR_LIST="$DROPBOX/todoist-colors.lst"
    SHIFTED_COLORS=$(awk '{if (NR == 1) {LINE=$0} else {print $0}} END {print LINE}' "$COLOR_LIST")
    echo "$SHIFTED_COLORS" >"$COLOR_LIST"
    head -n 1 "$COLOR_LIST"
}
rename_screen_cap() {
    NAME="$1"
    EXT="$2"
    TYPE="$3"
    DIR="$HOME/Desktop"
    RENAME="$DIR/$NAME.$EXT"
    SCREENCAP=$(find "$DIR" -maxdepth 1 -name "Screen $TYPE*.$EXT" | sort -n | tail -n 1)
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
sudo() {
    errcho -e "${CLR[RED]}[sudo] $@${CLR[END]}"
    "$(which sudo)" "$@"
}
# wl() { which "$@" && ls -l $(which "$@"); }
alias csc="cat $HOME/.ssh/config"
skg() { ssh-keygen -t rsa -b 4096 -o -a 100 -q -N '' -f "$HOME/.ssh/$1"; }

case "$OSTYPE" in
'darwin'*)
    alias q='no qlmanage -p'
    alias tp='open -a Typora'
    alias find='gfind'
    alias nwn='pkill brownnoise'
    alias pc='pbcopy'
    alias rc='launchctl stop homebrew.mxcl.chunkwm'
    alias ssh="TERM=linux $(which ssh)"
    alias wn='osascript -e "set Volume 2"; (no play -n synth brownnoise &)'
    ;;
'linux-gnu'*)
    q() { zathura "$1" & }
    alias tp='typora'
    alias dbs="dropbox status"
    alias kq='pkill -9 qutebrowser'
    alias fb="$HOME/.fehbg"
    alias wn="nohup play -n synth brownnoise pinknoise >/dev/null 2>&1 &"
    alias nn='pkill play'
    ;;
esac

alias ltvt='lt "${TMPDIR}markdown"*'
vt() {
    case "$OSTYPE" in
    'darwin'*)  # macOS does not honor TMPDIR or allow suffixes.
        TEMP="$(mktemp ${TMPDIR}markdown.XXXXXXXXXX)"
        rm "$TEMP"
        TEMP_MD="$TEMP.md"
        ;;
    'linux-gnu'*)
        TEMP="$(mktemp -t markdown.XXXXXXXXXX.md)"
        ;;
    esac
    touch "$TEMP_MD"
    tp "$TEMP_MD" &
    vim "$TEMP_MD"
}
