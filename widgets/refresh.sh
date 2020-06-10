#!/bin/bash

DIRNAME=$(dirname "$0")

echo '0' > /tmp/geo_time.txt
TMP_SCRIPT="$DIRNAME/refresh.tmp"
for SCRIPT in $(find "$DIRNAME" -maxdepth 1 -iname '*.coffee'); do
    echo "$SCRIPT -> $TMP_SCRIPT"
    mv "$SCRIPT" "$TMP_SCRIPT"
    sleep 0.1
    echo "$TMP_SCRIPT -> $SCRIPT"
    mv "$TMP_SCRIPT" "$SCRIPT"
done
