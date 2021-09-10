#!/bin/bash

# Various wrappers for ls.
if which exa &>/dev/null; then
    alias ll='exa -la'
    alias lt='ll -s mod'
    alias lh='ll -s size'
    alias lg='lt --git'
    alias tree='lt -T'
else
    case "$OSTYPE" in
    'linux-gnu'*)
        alias ls='ls --color'
        ;;
    'darwin'*)
        alias ls='ls -G'
        ;;
    esac
    alias ll='ls -lA'
    alias lt='ll -Frt'
    alias lh='ll -FrSh'
    # tree() { "$(which tree)" -taD "$@"; }
fi

# Search for files and optionally sort output by modification time or size.
if which fd &>/dev/null; then
    f() { fd -HI $@; }
    ff() {
        fd -HI -c always "$@" -x stat -c %y@%s@{} {} |
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

# Reduce ripgrep's level of "smart" searching. Two -u flags won’t respect
# .gitignore (etc.) files and will search hidden files and directories.
if which rg &>/dev/null; then
    rg() { $(which rg) -uu $@; }
fi

# Pretty-print filesystem information.
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

# Brief du. Wrote this a while ago and I think there are better options, like
# sharkdp/diskus.
TERA=1099511627776
GIGA=1073741824
MEGA=1048576
KILO=1024
dud() {
    du -s * | sort -rn | while read l; do
        SIZE=$(echo "$(echo \"$l\" | awk '{print $1}')*512" | bc)
        NAME=$(echo "$l" | sed -E 's/^[0-9]*[[:space:]]*//' |
            sed -E 's/[[:space:]]*$//')
        if [[ $SIZE -ge $GIGA ]]; then
            DENOM=$GIGA && DENOM_S="${red}GB${end}"
        elif [[ $SIZE -ge $MEGA ]]; then
            DENOM=$MEGA && DENOM_S="${yel}MB${end}"
        elif [[ $SIZE -ge $KILO ]]; then
            DENOM=$KILO && DENOM_S="${grn}KB${end}"
        else DENOM=1 && DENOM_S="${gry}B${end}"; fi
        python2 -c "print str(round(${SIZE}.0/$DENOM,2)) + str(\"|$DENOM_S|$NAME\")"
    done | column -t -s '|'
}

# Show file information. Useful for verifying file transfers, etc. Looks like:
# $ i /etc/passwd
# NAME: /etc/passwd
# SIZE: 2326 (2.3K)
# SHA1: af6eace97b8c0cf7bc0898254e15bdffe30bc70f
# TYPE: ASCII text
# $ i /dev/null
# NAME: /dev/null
# SIZE: 0 (0)
# SHA1: da39a3ee5e6b4b0d3255bfef95601890afd80709
# TYPE: character special (1/3)
i() {
    echo "NAME: $@"
    case "$OSTYPE" in
    'darwin'*)
        SIZE=$(stat -f %z "$@" | tr -d '\n')
        ;;
    'linux-gnu'*)
        SIZE=$(stat --printf='%s\n' "$@" | tr -d '\n')
        ;;
    esac
    echo -n "SIZE: $SIZE"
    if which numfmt &>/dev/null; then
        echo " ($(numfmt <<<"$SIZE" --to=iec))"
    else
        echo " ($(du -h $@ | awk '{print $1}'))"
    fi
    echo -n 'SHA1: '
    sha1sum "$@" | awk '{print $1}'
    echo -n 'TYPE: '
    file -b "$@"
}
