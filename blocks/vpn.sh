#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

VPN_CONNECTED=$(vpn_connected)
ALREADY_CONNECTED=$(cat /var/tmp/blocks/vpn-connected.txt)

if [[ "$VPN_CONNECTED" == 'false' ]]; then
    if [[ $ALREADY_CONNECTED == 'true' ]]; then
        rm /var/tmp/blocks/public-ip-{time,data}.txt 2>/dev/null
    fi
    # echo 'OFF'
    echo "$VPN_CONNECTED" >/var/tmp/blocks/vpn-connected.txt
    exit
else
    print_fa_icon 'shield-alt'
    if [[ $ALREADY_CONNECTED == 'false' ]]; then
        rm /var/tmp/blocks/public-ip-{time,data}.txt
    fi
    VPN_IFACE=$(get_vpn_iface)
    abbr_ipv4 $(get_iface_ipv4 "$VPN_IFACE")
    abbr_str $(get_vpn_name)
    echo -n ' '
    echo "$VPN_CONNECTED" >/var/tmp/blocks/vpn-connected.txt
fi
