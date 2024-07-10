#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

print_fa_icon 'arrow-up'
[[ "$NET_CONNECTED" == 'false' ]] && echo && exit

ROUTE_V4=$(get_default_route 'inet')
if ! [[ -z "$ROUTE_V4" ]]; then
    IP_V4=$(abbr_ipv4 $(awk <<<"$ROUTE_V4" '{print $1}'))
    IFACE_V4=$(awk <<<"$ROUTE_V4" '{print $2}')
    MAC_V4=$(get_neighbor 'inet' $(awk <<<"$ROUTE_V4" '{print $1}'))
    if [[ -n "$MAC_V4" ]]; then
        OUI_V4=$(sed <<<"$MAC_V4" -E 's/.{6}$//')
        VENDOR_V4=$(abbr_str $(get_vendor "$OUI_V4"))
    fi
fi

ROUTE_V6=$(get_default_route 'inet6')
if ! [[ -z "$ROUTE_V6" ]]; then
    IP_V6=$(awk <<<"$ROUTE_V6" '{print $1}')
    IFACE_V6=$(awk <<<"$ROUTE_V6" '{print $2}')
    MAC_V6=$(get_neighbor 'inet6' "$IP_V6")
    IP_V6=$(abbr_ipv6 $(sed <<<$IP_V6 -E 's/%.*//'))
    if [[ -n "$MAC_V6" ]]; then
        OUI_V6=$(sed <<<"$MAC_V6" -E 's/.{6}$//')
        VENDOR_V6=$(abbr_str $(get_vendor "$OUI_V6"))
    fi
fi

# Print results.
echo -n "$IP_V4 "
if [[ -n "$IP_V6" ]] && ! [[ "$IP_V6" =~ fe80(::|\*) ]]; then
    [[ "$MAC_V4" == "$MAC_V6" ]] || echo -n "$VENDOR_V4 / "
    echo -n "$IP_V6 "
    echo "$VENDOR_V6"
else
    echo "$VENDOR_V4"
fi

if [[ "$DEBUG" == 'true' ]]; then
    echo "IPv4 route:     \"$ROUTE_V4\""
    echo "IPv4 address:   \"$IP_V4\""
    echo "IPv4 interface: \"$IFACE_V4\""
    echo "IPv4 MAC:       \"$MAC_V4\""
    echo "IPv4 OUI:       \"$OUI_V4\""
    echo "IPv4 vendor:    \"$VENDOR_V4\""
    echo "IPv6 route:     \"$ROUTE_V6\""
    echo "IPv6 address:   \"$IP_V6\""
    echo "IPv6 interface: \"$IFACE_V6\""
    echo "IPv6 MAC:       \"$MAC_V6\""
    echo "IPv6 OUI:       \"$OUI_V6\""
    echo "IPv6 vendor:    \"$VENDOR_V6\""
fi
