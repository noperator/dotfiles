#!/usr/bin/env bash

source "$(dirname $0)/_abbr-ipv6.sh"
source "$(dirname $0)/.env"

# Get information about default route.
# @param $1 Protocol family to use. Can be inet or inet6.
# @return <GATEWAY-IP> <GATEWAY-IFACE>
get_default_route() {
    case "$OSTYPE" in
        'linux-gnu'*)
            ip -f "$1"  route | awk '$1 == "default" {print $3, $5}' | head -n 1
            ;;
        'darwin'*)
            ;;
    esac
}

# Get IPv4 address for an interface.
# @param $1 Interface name. e.g., en0, wlp3s1, eth2, etc.
# @return <IPV4-ADDR>
get_iface_ipv4() {
    case "$OSTYPE" in
        'linux-gnu'*)
            ip -4 addr show "$1" | perl -n -e "/inet ([^\/]+).* scope global/ && print \$1 and exit"
            ;;
        'darwin'*)
            ;;
    esac
}

# Get IPv6 address for an interface.
# @param $1 Interface name. e.g., en0, wlp3s1, eth2, etc.
# @return <IPV6-ADDR>
get_iface_ipv6() {
    case "$OSTYPE" in
        'linux-gnu'*)
            ip -6 addr show "$1" | grep -B 1 'sec' | awk 'NR == 1 {sub(/\/.*/, "", $2); print $2}'
            ;;
        'darwin'*)
            ;;
    esac
}

# Get a MAC address from an IP address.
# @param $1 Protocol family to use. Can be inet or inet6.
# @param $2 IP address to get MAC address for.
# @return <MAC-ADDR>
get_neighbor() {
    case "$OSTYPE" in
        'linux-gnu'*)
            MAC=$(ip -f "$1" neigh | awk -v "gw=$2" '{if ($1 == gw && $NF == "REACHABLE") {print $5}}' | sort -u)
            ;;
        'darwin'*)
            if [[ "$1" == 'inet' ]]; then
                MAC=$(arp -an | awk -v "gw=$2" '$2 == "("gw")" {print $4}')
            else
                MAC=$(ndp -an | awk -v "gw=$2" '$1 == gw {print $2}')
            fi
            ;;
    esac
    # if [[ -z "$MAC" ]]; then
    #     echo
    # else
    <<< "$MAC" awk '{split(toupper($0), mac, ":"); for (i = 1; i <= 6; i++) printf "%02s", mac[i]; print ""}' # | tr ' ' '0'
    # fi
}

# Get a vendor from a MAC address's OUI (first three octets).
# @param $1 OUI in all caps, no colon (e.g., A1B2C3).
# @return <VENDOR>
get_vendor() {
    awk -v "oui=$1" -F '\t' '$1 ~ oui {sub(/ .*/, "", $3); print $3}' "$(dirname $0)/oui.txt"
}

# Set global variables about interface state, connectivity, etc.
ETH_ENABLED='false'
WIFI_ENABLED='false'
WIFI_CONNECTED='false'
NET_CONNECTED='false'
case "$OSTYPE" in
    'linux-gnu'*)
        # Note: /sys/class/net/*/flags = 0x1003 (on) and 0x1002 (off).
        grep -E '0x1.03' "/sys/class/net/$ETH_IFACE/flags" &>/dev/null && ETH_ENABLED='true'
        grep -E '0x1.03' "/sys/class/net/$WIFI_IFACE/flags" &>/dev/null && WIFI_ENABLED='true'
        [[ "$WIFI_ENABLED" = 'true' ]] && ! iw dev "$WIFI_IFACE" link | grep 'Not connected.' &>/dev/null && WIFI_CONNECTED='true'
        grep -E '1' "/sys/class/net/$ETH_IFACE/carrier" &>/dev/null && ETH_CONNECTED='true'
        ;;
    'darwin'*)
        WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
        [[ "$WIFI_STATUS" != 'AirPort: Off' ]] && WIFI_ENABLED='true'
        [[ "$WIFI_ENABLED" = 'true' ]] && [[ "$(<<< "$WIFI_STATUS" awk '/state:/ {print $2}')" != 'init' ]] && WIFI_CONNECTED='true'
        ;;
esac
[[ "$WIFI_CONNECTED" == 'true' || "$ETH_CONNECTED" == 'true' ]] && NET_CONNECTED='true'

if [[ "$DEBUG" == 'true' ]]; then
    echo "Ethernet enabled:   $ETH_ENABLED"
    echo "Ethernet connected: $ETH_CONNECTED"
    echo "Wi-Fi enabled:      $WIFI_ENABLED"
    echo "Wi-Fi connected:    $WIFI_CONNECTED"
    echo "Network connected:  $NET_CONNECTED"
fi
