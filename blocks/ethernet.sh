#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

if [[ "$ETH_ENABLED" == 'false' ]]; then
    # echo 'OFF'
    echo 'off' >/var/tmp/blocks/ipv4-eth.txt
    exit
fi

print_fa_icon 'ethernet'
if [[ "$ETH_CONNECTED" == 'false' ]]; then
    echo 'none' >/var/tmp/blocks/ipv4-eth.txt
    echo 'NONE'
else
    get_iface_ipv4 "$ETH_IFACE" >/var/tmp/blocks/ipv4-eth.txt
    IPV4=$(abbr_ipv4 $(get_iface_ipv4 "$ETH_IFACE"))
    IPV6=$(abbr_ipv6 $(get_iface_ipv6 "$ETH_IFACE"))
    echo "$IPV4 $IPV6" | sed -E 's/ +$//'
fi
