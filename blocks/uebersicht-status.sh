#!/bin/bash

PATH="/opt/homebrew/bin:$PATH"
DIRNAME=$(dirname "$0")
source "$DIRNAME/.env"

mkdir -p -m 700 "$BLOCKS_DIR"

mv "$BLOCKS_DIR/ipv4-hash-new.txt" "$BLOCKS_DIR/ipv4-hash-old.txt" 2>/dev/null
cat "$BLOCKS_DIR"/ipv4-{pub,wif,eth}.txt 2>/dev/null | sort | shasum | cut -f 1 -d ' ' >"$BLOCKS_DIR/ipv4-hash-new.txt"

(
    # speed \
    # vpn \
    # timer \
    for SCRIPT in \
        public-ip \
        gateway \
        wifi \
        ethernet; do
        "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
    done

    # These items don't contain sensitive information.
    # airpods \
    # trackpad \
    for SCRIPT in \
        battery \
        date; do
        "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
    done
) | sed -E 's/ +/ /g'
