#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_abbr-ipv6.sh"
source "$(dirname $0)/_network.sh"
source "$(dirname $0)/.env"

get_gateway() {
    case "$OSTYPE" in
        'linux-gnu'*)
            ip -f "$1" route | awk -v "iface=$GATEWAY_IFACE" '{if ($1 == "default" && $5 == iface) print $3}'
            ;;
        'darwin'*)
            netstat -rnf "$1" | awk -v "iface=$GATEWAY_IFACE" '{if ($1 == "default" && $4 == iface) print $2}'
            ;;
    esac
}

get_neighbor() {  # <inet(6)> <IP-ADDR>
    case "$OSTYPE" in
        'linux-gnu'*)
            MAC=$(ip -f "$1" neigh | awk -v "gw=$2" '$1 == gw {print $5}')
            ;;
        'darwin'*)
            if [[ "$1" == 'inet' ]]; then
                # NEIGH_CMD='arp'
                MAC=$(arp -an | awk -v "gw=$2" '$2 == "("gw")" {print $4}')
            else
                # NEIGH_CMD='ndp'
                MAC=$(ndp -an | awk -v "gw=$2" '$1 == gw {print $2}')
            fi
            ;;
    esac
    <<< "$MAC" awk '{split(toupper($0), mac, ":"); for (i = 1; i <= 6; i++) printf "%02s", mac[i]; print ""}' | tr ' ' '0'
}

# Note: Could instead use nmap's OUI list at /usr/local/share/nmap/nmap-mac-prefixes.
get_vendor() {
    awk -v "oui=$1" -F '\t' '$1 ~ oui {sub(/ .*/, "", $3); print $3}' "$(dirname $0)/oui.txt"
}

# Get IPv4 gateway, MAC, OUI (first three octets), and vendor.
GATEWAY_V4=$(get_gateway 'inet')
if ! [[ -z "$GATEWAY_V4" ]]; then
    MAC_V4=$(get_neighbor 'inet' "$GATEWAY_V4")
    OUI_V4=$(<<< "$MAC_V4" sed -E 's/.{6}$//')
    VENDOR_V4=$(get_vendor "$OUI_V4")
fi

# Get IPv6 gateway, MAC, OUI (first three octets), and vendor.
GATEWAY_V6=$(get_gateway 'inet6')
if ! [[ -z "$GATEWAY_V6" ]]; then
    MAC_V6=$(get_neighbor 'inet6' "$GATEWAY_V6")
    OUI_V6=$(<<< "$MAC_V6" sed -E 's/.{6}$//')
    VENDOR_V6=$(get_vendor "$OUI_V6")
fi

# Print results.
print_fa_icon 'arrow-up'
[[ "$WIFI_CONNECTED" == 'false' ]] && echo && exit
echo -n "$GATEWAY_V4 "
if ! [[ -z "$GATEWAY_V6" ]]; then
    [[ "$MAC_V4" == "$MAC_V6" ]] || echo -n "$VENDOR_V4 / "
    echo -n "$(abbr_ipv6 $(<<< $GATEWAY_V6 sed -E 's/%.*//')) "
    echo "$VENDOR_V6"
else
    echo "$VENDOR_V4"
fi
