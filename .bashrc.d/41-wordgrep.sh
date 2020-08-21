#!/bin/bash

wg() {
    rg -i "$@" /usr/share/dict/words | while read WORD; do
        <<< "$WORD" wc -c | tr -d '\n'
        echo " $WORD"
    done | sort -rn | column -t | grep -iE --color=always "$@"
}
