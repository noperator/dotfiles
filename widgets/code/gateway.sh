#!/bin/bash

source "$(dirname $0)/abbr_ipv6.sh"

IFACE='en0'

get_gateway() {
    netstat -rnf "$1" | awk -v "iface=$IFACE" '{if ($1 == "default" && $4 == iface) print $2}'
}

# Note: Could instead use nmap's OUI list at /usr/local/share/nmap/nmap-mac-prefixes.
get_vendor() {
    awk -v "oui=$1" -F '\t' '$1 ~ oui {sub(/ .*/, "", $3); print $3}' "$(dirname $0)/oui.txt"
}

# Get IPv4 gateway, MAC, OUI (first three octets), and vendor.
GATEWAY_V4=$(get_gateway 'inet')
if ! [[ -z "$GATEWAY_V4" ]]; then
    MAC_V4=$(arp -an | awk -v "gw=$GATEWAY_V4" '$2 == "("gw")" {split(toupper($4), mac, ":"); for (i = 1; i <= 6; i++) printf "%02s", mac[i]; print ""}')
    OUI_V4=$(<<< "$MAC_V4" sed -E 's/.{6}$//')
    VENDOR_V4=$(get_vendor "$OUI_V4")
fi

# Get IPv6 gateway, MAC, OUI (first three octets), and vendor.
GATEWAY_V6=$(get_gateway 'inet6')
if ! [[ -z "$GATEWAY_V6" ]]; then
    MAC_V6=$(ndp -an | awk -v "gw=$GATEWAY_V6" '$1 == gw {split(toupper($2), mac, ":"); for (i = 1; i <= 6; i++) printf "%02s", mac[i]; print ""}')
    OUI_V6=$(<<< "$MAC_V6" sed -E 's/.{6}$//')
    VENDOR_V6=$(get_vendor "$OUI_V4")
fi

# Print results.
echo -n '@arrow-up@ '
echo -n "$GATEWAY_V4 "
if ! [[ -z "$GATEWAY_V6" ]]; then
    [[ "$MAC_V4" == "$MAC_V6" ]] || echo -n "$VENDOR_V4 / "
    echo -n "$(abbr_ipv6 $(<<< $GATEWAY_V6 sed -E 's/%.*//' )) "
    echo "$VENDOR_V6"
else
    echo "$VENDOR_V4"
fi
