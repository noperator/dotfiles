#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"

echo '🔑'
echo '🔑'

if [[ `/usr/bin/pgrep fprintd` ]]; then
    echo "$GREEN"
else
    echo "$BLACK"
fi
