#!/bin/bash

which nvim &>/dev/null && alias vim='nvim'
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
alias bc='bc -lq'
alias cal3='ncal -b3'
vcal() {
    for MON in $@; do
        cal -m "$MON" |
            grep -viE "$MON|^ *$|^Su"
    done |
        tr '\n' '@' |
        sed -E 's/ +@ +1 /  1 /g' |
        tr '@' '\n'
}
rtc() { # Random Todoist color
    COLOR_LIST="$DROPBOX/todoist/todoist-colors.lst"
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

alias ssh="TERM=xterm-256color $(which ssh)"
case "$OSTYPE" in
'darwin'*)
    q() { no qlmanage -p "$1"; }
    alias tp='open -a Typora'
    alias find='gfind'
    alias nwn='pkill brownnoise'
    alias pc='pbcopy'
    alias rc='launchctl stop homebrew.mxcl.chunkwm'
    alias wn='osascript -e "set Volume 2"; (no play -n synth brownnoise &)'
    ;;
'linux-gnu'*)
    q() {
        if file "$1" | grep -qi pdf; then
            zathura "$1" &
        else # Probably an image.
            feh "$1" &
        fi
    }
    alias tp='typora'
    alias dbs="dropbox status"
    alias kq='pkill -9 qutebrowser'
    alias fb="$HOME/.fehbg"

    # Freq (Hz)      Center  Width  Octave      Description
    # ---------      ------  -----  ------      -----------
    # 16   to    32  24      16     1st         Human threshold, the lowest pedal notes of a pipe organ.
    # 32   to   512  272     480    2nd to 5th  Rhythm frequencies, where the lower and upper bass notes lie.
    # 512  to  2048  1280    1536   6th to 7th  Defines human speech intelligibility, gives a horn-like or tinny quality to sound.
    # 2048 to  8192  5120    6144   8th to 9th  Gives presence to speech, where labial and fricative sounds lie.
    # 8192 to 16384  12288   8192   10th        Brilliance, the sounds of bells and the ringing of cymbals. In speech, the sound of the letter "S" (8000-11000 Hz).
    #
    # More examples here:
    # - https://gist.github.com/rsvp/1209835/7fa91788f7e08d2f95b6a20deda3f528042d3e27
    alias wn="nohup play -nq -c 2 synth brownnoise band 5120 6144 &>/dev/null &"
    alias nn="$(which pkill) play"

    alias pc='xclip'
    alias susp='systemctl suspend'
    ;;
esac

# alias ltvt='lt "${TMPDIR}markdown"*'
vt() {
    case "$OSTYPE" in
    'darwin'*) # macOS does not honor TMPDIR or allow suffixes.
        TEMP="$(mktemp ${TMPDIR}markdown.XXXXXXXXXX)"
        rm "$TEMP"
        TEMP_MD="$TEMP.md"
        ;;
    'linux-gnu'*)
        if [[ -d "$HOME/tmp" ]]; then
            TEMP_MD="$(mktemp -p "$HOME/tmp" markdown.XXXXXXXXXX.md)"
        else
            TEMP_MD="$(mktemp -t markdown.XXXXXXXXXX.md)"
        fi
        ;;
    esac
    touch "$TEMP_MD"
    echo "$TEMP_MD"
    tp "$TEMP_MD" &
    vim "$TEMP_MD"
}

# Get random line from file.
rand_line() {
    NUM_LINES=$(wc -l $1 | awk '{print $1}')
    LINE_NUM=$(shuf -i 1-$NUM_LINES -n 1)
    sed "${LINE_NUM}q;d" "$1"
}

# Random adjective-noun.
ran() {
    WORDS_DIR="$HOME/.local/share/words"
    for WORDS in adjectives.txt nouns.txt; do
        echo -n $(rand_line "$WORDS_DIR/$WORDS")
    done
    echo
}

# Emoji Finder. CLI doesn't always handle compound emojis well (e.g., "cuba" or
# "astronaut"), so if anything looks funky, just visit the Emoji Finder URL
# printed before the results.
# - https://eclecticlight.co/2018/03/15/compound-emoji-can-confuse/
ef() {
    echo "https://emojifinder.com/$1"
    curl -s "https://emojifinder.com/*/ajax.php?action=search&query=$1" |
        jq -r '.results | sort_by(.display_mode) | .[] | [.display_code, .Name] | join("@")' |
        while IFS=@ read CODE NAME; do
            echo -e "$(sed <<<$CODE -E 's/&#x(.*);/\\U\1/')@$(tr <<<$NAME '[:upper:]' '[:lower:]')"
        done |
        column -t -s '@'
}

# GIMP screenshot.
gsc() {
    gimp $(find "$HOME/screenshots/" -maxdepth 1 -type f |
        grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}-[0-9]{2}.[0-9]{9}\.png' |
        sort -V |
        tail -n 1)
}
