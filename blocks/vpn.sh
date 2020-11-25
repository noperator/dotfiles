#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

VPN_ENABLED=$(vpn_connected)

print_fa_icon 'shield-alt'
if [[ "$VPN_ENABLED" == 'false' ]]; then
    echo 'OFF'
else
    VPN_IFACE=$(get_vpn_iface)
    get_iface_ipv4 "$VPN_IFACE" | tr '\n' ' '
    get_vpn_name
fi
