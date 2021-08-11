#!/bin/bash

# Toggle the value of the PUBLIC_IP variable which, when equal to -1, will
# disable the public IP address block from being displayed in i3blocks.
source "$(dirname $0)/.env"
sed -i -E "s/(^PUBLIC_IP=).*/\1$((PUBLIC_IP * -1))/" "$(dirname $0)/.env"

# Reload the public IP block.
PUBLIC_IP_SIGNAL=$(
    grep -E 'public-ip|signal' "$HOME/.config/i3blocks/config" |
        grep -A 1 'public-ip' |
        tail -n 1 |
        cut -d = -f 2
)
$(which pkill) --signal "SIGRTMIN+$PUBLIC_IP_SIGNAL" i3blocks
