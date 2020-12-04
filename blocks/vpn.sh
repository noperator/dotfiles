#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

VPN_CONNECTED=$(vpn_connected)
ALREADY_CONNECTED=$(cat /var/tmp/vpn-connected.txt)

print_fa_icon 'shield-alt'
if [[ "$VPN_CONNECTED" == 'false' ]]; then
    if [[ $ALREADY_CONNECTED == 'true' ]]; then
        rm /var/tmp/public-ip-{time,data}.txt
    fi
    echo 'OFF'
else
    if [[ $ALREADY_CONNECTED == 'false' ]]; then
        rm /var/tmp/public-ip-{time,data}.txt
    fi
    VPN_IFACE=$(get_vpn_iface)
    get_iface_ipv4 "$VPN_IFACE" | tr '\n' ' '
    get_vpn_name
fi

echo "$VPN_CONNECTED" > /var/tmp/vpn-connected.txt
