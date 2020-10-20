#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"
source "$(dirname $0)/_network.sh"

RESULTS=$(speedtest-cli --single --simple --bytes)

UPLOAD=$(echo "$RESULTS" | awk '$1 == "Upload:" {print $2}')
DOWNLOAD=$(echo "$RESULTS" | awk '$1 == "Download:" {print $2}')

echo "↑ ${UPLOAD}M ↓ ${DOWNLOAD}M"
echo "↑ ${UPLOAD}M ↓ ${DOWNLOAD}M"
echo

