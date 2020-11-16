#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

VPN_ENABLED='false'
pgrep openvpn &>/dev/null && VPN_ENABLED='true'

print_fa_icon 'shield-alt'
if [[ "$VPN_ENABLED" == 'false' ]]; then
    echo 'OFF'
else
    get_iface_ipv4 "$VPN_IFACE"
fi
