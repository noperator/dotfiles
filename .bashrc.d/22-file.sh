#!/bin/bash

case "$OSTYPE" in 
    'linux-gnu')
        alias ls='ls --color'
        ;;
    'darwin'*)
        alias ls='ls -G'
        ;;
esac

alias ll='ls -lA'
alias lt='ll -Frt'
alias lh='ll -FrSh'
ff() { find "$@" ! -empty -type f -printf '%.19T+@%s@%p\n' 2>/dev/null | while read LINE; do printf '%q\n' "$LINE"; done | column -t -s '@' | cut -c -"$COLUMNS"; }
ft() { ff "$@" | sort -n; }
fs() { ff "$@" | sort -n -k 2; }
tree() { "$(which tree)" -taD "$@" | ccat; }
alias mount="$(which mount) | sed -E 's/ on |\(|\)/@/g' | column -t -s @ | cut -c -\$COLUMNS"

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
