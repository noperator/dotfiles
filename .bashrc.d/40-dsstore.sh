#!/bin/bash

mds() {
    mkdir -p /var/tmp/ds_store
    gfind $1 -path /var/tmp -prune -o -name '.DS_Store' -type f 2>/dev/null | while read f; do
        echo "$f"
        FILE=$(echo "${f}_$(date +%s)" | tr '/' '_')
        mv "$f" "/var/tmp/ds_store/$FILE"
    done
}
