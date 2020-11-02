#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

print_fa_icon 'arrow-up'
[[ "$NET_CONNECTED" == 'false' ]] && echo && exit

ROUTE_V4=$(get_default_route 'inet')
if ! [[ -z "$ROUTE_V4" ]]; then
    IP_V4=$(<<< "$ROUTE_V4" awk '{print $1}')
    IFACE_V4=$(<<< "$ROUTE_V4" awk '{print $2}')
    MAC_V4=$(get_neighbor 'inet' "$IP_V4")
    OUI_V4=$(<<< "$MAC_V4" sed -E 's/.{6}$//')
    VENDOR_V4=$(get_vendor "$OUI_V4")
fi

ROUTE_V6=$(get_default_route 'inet6')
if ! [[ -z "$ROUTE_V6" ]]; then
    IP_V6=$(<<< "$ROUTE_V6" awk '{print $1}')
    IFACE_V6=$(<<< "$ROUTE_V6" awk '{print $2}')
    MAC_V6=$(get_neighbor 'inet6' "$IP_V6")
    IP_V6=$(abbr_ipv6 $(<<< $IP_V6 sed -E 's/%.*//'))
    OUI_V6=$(<<< "$MAC_V6" sed -E 's/.{6}$//')
    VENDOR_V6=$(get_vendor "$OUI_V6")
fi

# Print results.
echo -n "$IP_V4 "
if ! [[ -z "$IP_V6" ]]; then
    [[ "$MAC_V4" == "$MAC_V6" ]] || echo -n "$VENDOR_V4 / "
    echo -n "$IP_V6 "
    echo "$VENDOR_V6"
else
    echo "$VENDOR_V4"
fi
