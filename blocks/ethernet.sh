#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

print_fa_icon 'ethernet'
if [[ "$ETH_ENABLED" == 'false' ]]; then
    echo 'OFF'
elif [[ "$ETH_CONNECTED" == 'false' ]]; then
    echo 'NONE'
else
    IPV4=$(get_iface_ipv4 "$ETH_IFACE")
    IPV6=$(abbr_ipv6 $(get_iface_ipv6 "$ETH_IFACE"))
    echo "$IPV4 $IPV6" | sed -E 's/ +$//'
fi
