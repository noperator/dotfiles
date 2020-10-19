#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"
source "$(dirname $0)/meminfo.sh"

SWAP=$(getmem swap)

echo "⇄ $SWAP"
echo "⇄ $SWAP"
echo
