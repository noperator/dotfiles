#!/bin/bash

case "$OSTYPE" in 
    'linux-gnu'*)
        alias ls='ls --color'
        ;;
    'darwin'*)
        alias ls='ls -G'
        ;;
esac

if which exa &>/dev/null; then
    alias ll='exa -la'
    alias lt='ll -s mod'
    alias lh='ll -s size'
    alias tree='lt -T'
else
    alias ll='ls -lA'
    alias lt='ll -Frt'
    alias lh='ll -FrSh'
    # tree() { "$(which tree)" -taD "$@"; }
fi

if which fd &>/dev/null; then
    f() { fd $@; }
    ff() {
        fd -c always "$@" -x stat -c %y@%s@{} {} |
            sed -E 's/ /T/; s/\.[^@]*//' |
            column -t -s '@' |
            cut -c -"$COLUMNS"
    }
    ft() { ff "$@" | sort -n; }
    fs() { ff "$@" | sort -n -k 2; }
else
    f() { find . -iname '*'"$@"'*'; }
    ff() {
        find "$@" ! -empty -type f -printf '%.19T+@%s@%p\n' 2>/dev/null |
            while read LINE; do
                printf '%q\n' "$LINE"
            done |
            column -t -s '@' |
            cut -c -"$COLUMNS"
    }
    ft() { ff "$@" | sort -n; }
    fs() { ff "$@" | sort -n -k 2; }
fi

alias mount="$(which mount) | sed -E 's/ on |\(|\)/#/g' | column -t -s '#' | cut -c -\$COLUMNS"

# Inspired by options like namei, chase, typex, and rreadlink, all documented
# at https://stackoverflow.com/q/33255460.
wl() {
    case $(type -t "$1") in
    'file')
        FILE=$(which "$1")
        TYPE=$(file "$FILE")
        while [[ "$TYPE" == *'symbolic link'* ]]; do
            echo "-> $FILE" >&2
            LINK=$(readlink "$FILE")
            if [[ "$LINK" != /* ]]; then
                DIR=$(dirname "$FILE")
                FILE="$DIR/$LINK"
            else
                FILE="$LINK"
            fi
            TYPE=$(file "$FILE")
        done
        echo "$FILE"
        ;;
    *)
        type "$1"
        ;;
    esac
}

TERA=1099511627776
GIGA=1073741824
MEGA=1048576
KILO=1024
dud() {
  du -s * | sort -rn | while read l; do
    SIZE=$( echo "`echo \"$l\" | awk '{print $1}'`*512" | bc )
    NAME=$( echo "$l" | sed -E 's/^[0-9]*[[:space:]]*//' |\
            sed -E 's/[[:space:]]*$//' )
    if   [[ $SIZE -ge $GIGA ]]; then DENOM=$GIGA && DENOM_S="${red}GB${end}"
    elif [[ $SIZE -ge $MEGA ]]; then DENOM=$MEGA && DENOM_S="${yel}MB${end}"
    elif [[ $SIZE -ge $KILO ]]; then DENOM=$KILO && DENOM_S="${grn}KB${end}"
    else                             DENOM=1     && DENOM_S="${gry}B${end}"; fi
    python2 -c "print str(round(${SIZE}.0/$DENOM,2)) + str(\"|$DENOM_S|$NAME\")"
  done | column -t -s '|'
}

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
    echo -n 'SHA1: '
    sha1sum "$@" | awk '{print $1}'
    echo -n 'TYPE: '
    file -b "$@"
}
