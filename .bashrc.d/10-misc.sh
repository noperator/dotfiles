#!/bin/bash

alias de='date "+%s"'
alias ec='exiftool -overwrite_original_in_place -all=""'
alias errcho='>&2 echo'
alias et="TERM=linux $(which et 2>/dev/null)"
alias vd='vimdiff'
alias l='clear'
alias less='less -i'
alias no='>/dev/null 2>&1'
alias g='grep -iE --color'
alias vg='g -v'
alias cls='printf "\033c"'
alias sudoedit="EDITOR=$EDITOR sudoedit"
alias sus='sort | uniq -c | sort -n'
alias sba='source venv/bin/activate'
if which hexyl &>/dev/null; then
    alias hd='hexyl'
else
    alias hd='hexdump -C'
fi

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
csc() {
    # bat --paging never --style plain "$HOME"/.ssh/{config,*/config}
    cat "$HOME"/.ssh/{config,*/config}
}
skg() { ssh-keygen -t rsa -b 4096 -o -a 100 -q -N '' -f "$HOME/.ssh/$1"; }

alias ssh="TERM=xterm-256color $(which ssh)"
case "$OSTYPE" in
'darwin'*)
    q() { no qlmanage -p "$1"; }
    alias tp='open -a Typora'
    which gfind &>/dev/null && alias find='gfind'
    which gdate &>/dev/null && alias date='gdate'
    alias nwn='pkill brownnoise'
    alias pc='pbcopy'
    alias rc='launchctl stop homebrew.mxcl.chunkwm'
    alias wn='osascript -e "set Volume 2"; (play -nq -c 2 synth brownnoise band 5120 6144 &>/dev/null &)'
    switchresx() {
        open "$HOME/Library/PreferencePanes/SwitchResX.prefPane/Contents/PlugIns/SwitchResX Control.app"
    }
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

# URL decode.
# - https://stackoverflow.com/a/37840948
urldecode() {
    : "${*//+/ }"
    echo -e "${_//%/\\x}"
}

# Get synonyms.
th() {
    URL="https://www.thesaurus.com/browse/$1"
    echo "$URL"
    BODY=$(curl -s "$URL")

    echo "$BODY" | htmlq -t '#headword li strong, #headword li em' |
        paste - - | sed -E 's/^/- /'
    echo

    echo "$BODY" |
        htmlq -t '#meanings li' |
        sed -E 's/\.css.*\}/==\n/' |
        awk 'BEGIN {C = -1} {if ($0 == "==") {R = 0; C += 1} else {R += 1; if (C > 0) {ROWS[R] = ROWS[R] ","}; ROWS[R] = ROWS[R] $0}} END {for (R in ROWS) print ROWS[R]}' |
        column -ts,
}

cgu() {
    case $(
        curl \
            -s 'https://accounts.google.com/_/signup/webusernameavailability' \
            -H 'google-accounts-xsrf: 1' \
            -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
            -d "f.req=$(jo -a -- -s '' -s '' -s '' $1 true -s "" 1)" |
            tail -n 1 |
            jq 'map(.[1])[]'
    ) in
    1)
        echo 'available'
        ;;
    2)
        echo 'taken'
        ;;
    3)
        echo 'invalid'
        ;;
    *)
        echo 'unknown'
        ;;
    esac
}

gfu() {
    echo -n 'https://grepfeed.sigwait.tk/api?url='
    echo "$1" | jq -Rr '@uri'
}

# number html lines
nln() {
    nl -nln | sed -E "s/(^[0-9]+)/\1.$1/"
}

fad() {
    curl -s 'https://www.fakepersongenerator.com/Random/generate_address' -d 'state=0&city=&zip=' |
        htmlq '.info-detail > input' -a value |
        head -n 6
}

alias tl='tmux ls'
alias tn='tmux new -s'
alias ta='tmux attach -t'
_tmux_session_complete() {
    local cur_word="${COMP_WORDS[COMP_CWORD]}"
    local sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null)

    COMPREPLY=($(compgen -W "$sessions" -- "$cur_word"))
}
complete -F _tmux_session_complete ta
