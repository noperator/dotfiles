#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"
source "$(dirname $0)/.env"

print_fa_icon 'ethernet'
if [[ "$ETH_ENABLED" == 'false' ]]; then
    echo 'OFF'
else
    IPV4=$(get_iface_ipv4 "$ETH_IFACE")
    IPV6=$(abbr_ipv6 $(get_iface_ipv6 "$ETH_IFACE"))
    if [[ -z "$IPV4" ]] && [[ -z "$IPV6" ]]; then
        echo 'NONE'
    else
        echo "$IPV4 $IPV6"
    fi
fi
