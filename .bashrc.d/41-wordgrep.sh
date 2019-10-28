#!/bin/bash

wg() {
    grep -iE "$@" /usr/share/dict/words | while read WORD; do
        echo "$WORD" | wc -c | tr -d '\n'
        echo " $WORD"
    done | sort -rn | column -t | grep -iE --color=always "$@"
}
