#!/usr/bin/env bash

export LC_ALL=en_US.UTF-8

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

# touch $BLOCKS_DIR/speed-data.txt
PATH="$HOME/go/bin:$PATH"

cp "$(ls -tr "$BLOCKS_DIR"/speed-data-*.txt 2>/dev/null | tail -n 1)" "$BLOCKS_DIR/speed-data.txt" 2>/dev/null

# TODO:
# - Make speedtest run in background.
# if [[ -z $(sed -E 's|[/ ]*||g' $BLOCKS_DIR/speed-data.txt) ]] &&
# if ! diff $BLOCKS_DIR/ipv4-hash-* >/dev/null &&
DATA=$(cat "$BLOCKS_DIR/speed-data.txt" 2>/dev/null)
DIFF=$(diff "$BLOCKS_DIR"/ipv4-hash-*)
PROC=$(pgrep -f ndt7-client)
CHECK='false'
# if [[ -z $(sed -E 's|[/ ]*||g' $BLOCKS_DIR/speed-data.txt) ]] ||
#     ! diff $BLOCKS_DIR/ipv4-hash-* >/dev/null &&
#     [[ ! $(pgrep -f ndt7-client) ]]; then

if [[ (-z "$DATA" ||
    -n "$DIFF") &&
    -z "$PROC" ]]; then

    CHECK='true'

    # if grep -qiE 'veriz|t.?mob' $BLOCKS_DIR/public-ip-data.txt; then
    #     echo mobile >$BLOCKS_DIR/speed-data-mobile.txt
    # else
    ndt7-client -format=json | tail -n 1 |
        jq '.Download, .Upload | .Value | round' | tr '\n' ' ' >"$BLOCKS_DIR/speed-data-$(date +%s).txt" &
    # fi
fi

# if [[ "$DEBUG" == 'true' ]]; then
# (
#     echo "Data:  \"$DATA\""
#     echo "Diff:  \"$DIFF\""
#     echo "Proc:  \"$PROC\""
#     echo "Check: \"$CHECK\""
# ) >$BLOCKS_DIR/speed-debug-$(date +%s).txt
# fi

print_fa_icon 'tachometer-alt'
if [[ "$NET_CONNECTED" == 'false' ]]; then
    echo 'NONE'
    rm "$BLOCKS_DIR/speed-data.txt" 2>/dev/null
else
    cat "$BLOCKS_DIR/speed-data.txt" 2>/dev/null
fi
