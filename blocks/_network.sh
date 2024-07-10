#!/usr/bin/env bash

source "$(dirname $0)/_abbreviate.sh"
source "$(dirname $0)/.env"

# Get information about default route.
# @param $1 Protocol family to use. Can be inet or inet6.
# @return <GATEWAY-IP> <GATEWAY-IFACE>
get_default_route() {
    case "$OSTYPE" in
    'linux-gnu'*)
        ip -f "$1" route | awk '$1 ~ "default|0/1" {print $3, $5}' | head -n 1
        ;;
    'darwin'*)
        netstat -rnf "$1" | awk '$1 ~ "default|0/1" {print $2, $4}' | head -n 1
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
        ifconfig "$1" inet | awk '$1 == "inet" {print $2}'
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
        ifconfig "$1" inet6 | awk '{if ($6 == "temporary" && ! match($2, "^f[cd]")) print $2}'
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
        # Used to check the neighbor state, but that value switches between
        # "reachable," "stale," and "delay" every few minutes which would
        # cause the status bar to flicker with those value changes in a
        # distracting way. For my purposes, I decided it's fine to ignore
        # the state.
        # MAC=$(ip -f "$1" neigh | awk -v "gw=$2" '{if ($1 == gw && $NF == "REACHABLE") {print $5}}' | sort -u)
        MAC=$(ip -f "$1" neigh | awk -v "gw=$2" '{if ($1 == gw) {print $5}}' | sort -u)
        ;;
    'darwin'*)
        if [[ "$1" == 'inet' ]]; then
            MAC=$(arp -an | awk -v "gw=$2" '$2 == "("gw")" {print $4}')
        else

            MAC=$(ndp -an 2>/dev/null | awk -v "gw=$2" '$1 == gw {print $2}')
        fi
        ;;
    esac
    if [[ -z "$MAC" ]]; then
        echo
    else
        sort <<<"$MAC" -u | awk '{split(toupper($0), mac, ":"); for (i = 1; i <= 6; i++) printf "%02s", mac[i]; print ""}' | tr ' ' '0'
    fi
}

# Get a vendor from a MAC address's OUI (first three octets). Update OUIs like this:
# ```
# curl -s https://gitlab.com/wireshark/wireshark/-/raw/master/manuf |
# 	grep -vE '^(#|$)' | awk '{gsub(/:/, "", $1); print}' >oui.txt
# ```
# @param $1 OUI in all caps, no colon (e.g., A1B2C3).
# @return <VENDOR>
get_vendor() {
    # awk -v "oui=$1" -F '\t' '$1 ~ oui {sub(/[, ].*/, "", $3); print $3}' "$(dirname $0)/oui.txt"
    awk -v "oui=$1" '$1 ~ oui {print $2}' "$(dirname $0)/oui.txt"
}

# Determine if interface is enabled.
# @param $1 Interface name. e.g., en0, wlp3s1, eth2, etc.
# @return <BOOLEAN> true or false.
iface_enabled() {
    case "$OSTYPE" in
    'linux-gnu'*)
        awk <"/sys/class/net/$1/flags" '{if ($1 == "0x1003") {print "true"} else {print "false"}}'
        ;;
    'darwin'*)
        ifconfig "$1" | awk '$2 ~ /flags=/ {if ($2 ~ /RUNNING/) {print "true"} else {print "false"}}'
        ;;
    esac
}

# Determine if Ethernet cable is plugged in.
# @param $1 Ethernet interface name. e.g., en3, eth2, etc.
# @return <BOOLEAN> true or false.
ethernet_connected() {
    case "$OSTYPE" in
    'linux-gnu'*)
        if grep -E '1' "/sys/class/net/$1/carrier" &>/dev/null; then
            echo 'true'
        else
            echo 'false'
        fi
        ;;
    'darwin'*)
        ifconfig "$1" | awk '$1 == "status:" {if ($2 == "active") {print "true"} else {print "false"}}'
        ;;
    esac
}

# Determine if associated with Wi-Fi access point.
# @param $1 Wi-Fi interface name. e.g., en0, wlp3s1, etc.
# @return <BOOLEAN> true or false.
wifi_connected() {
    case "$OSTYPE" in
    'linux-gnu'*)
        awk <"/sys/class/net/$1/operstate" '{if ($1 == "up") {print "true"} else {print "false"}}'
        ;;
    'darwin'*)
        ifconfig "$1" | awk '$1 == "status:" {if ($2 == "active") {print "true"} else {print "false"}}'
        ;;
    esac
}

# Determine if interface exists.
# @param $1 Interface name. e.g., en0, wlp3s1, eth2, etc.
# @return <BOOLEAN> true or false.
iface_exists() {
    case "$OSTYPE" in
    'linux-gnu'*)
        if ip link show dev "$1" &>/dev/null; then
            echo 'true'
        else
            echo 'false'
        fi
        ;;
    'darwin'*)
        if ifconfig "$1" &>/dev/null; then
            echo 'true'
        else
            echo 'false'
        fi
        ;;
    esac
}

# Check if VPN connected.
# @return <BOOLEAN> true or false.
vpn_connected() {
    case "$OSTYPE" in
    'linux-gnu'*)
        if pgrep openvpn &>/dev/null; then
            echo 'true'
        else
            echo 'false'
        fi
        ;;
    'darwin'*)
        # if osascript \
        #     -e 'tell application "/Applications/Tunnelblick.app"' \
        #     -e 'get state of configurations' \
        #     -e 'end tell' |
        if osascript \
            -e 'tell application "Viscosity"' \
            -e 'get state of first connection' \
            -e 'end tell' |
            grep -iq '^connected$'; then
            echo 'true'
        else
            echo 'false'
        fi
        ;;
    esac
}

# Get interface of active VPN connection.
# @return <VPN-IFACE>
get_vpn_iface() {
    case "$OSTYPE" in
    'linux-gnu'*) ;;

    'darwin'*)
        # cat /Library/Application\ Support/Tunnelblick/Logs/*.openvpn.log |
        #     sort -n |
        #     awk '{if ($3 == "/sbin/ifconfig" && $NF == "up") {print $4}}' |
        #     tail -n 1
        IPV4=$(osascript \
            -e 'tell application "Viscosity"' \
            -e 'get IPv4Address of first connection' \
            -e 'end tell')
        ifconfig | grep -E '^[a-z0-9]+:|inet ' | grep -B 1 "$IPV4" | head -n 1 | cut -d : -f 1
        ;;
    esac

}

# Get name of active VPN connection.
# @return <VPN-IFACE>
get_vpn_name() {
    case "$OSTYPE" in
    'linux-gnu'*) ;;

    'darwin'*)
        # osascript \
        #     -e 'tell application "/Applications/Tunnelblick.app"' \
        #     -e 'get name of configuration 1 whose state = "CONNECTED"' \
        #     -e 'end tell'
        osascript \
            -e 'tell application "Viscosity"' \
            -e 'get name of connection 1 whose state = "connected"' \
            -e 'end tell'
        ;;
    esac
}

# Set global variables about interface state, connectivity, etc.
if [[ $(iface_exists "$ETH_IFACE") == 'true' ]]; then
    ETH_ENABLED=$(iface_enabled "$ETH_IFACE")
    ETH_CONNECTED=$(ethernet_connected "$ETH_IFACE")
else
    ETH_ENABLED='false'
    ETH_CONNECTED='false'
fi
WIFI_ENABLED=$(iface_enabled "$WIFI_IFACE")
WIFI_CONNECTED=$(wifi_connected "$WIFI_IFACE")
if [[ "$WIFI_CONNECTED" == 'true' || "$ETH_CONNECTED" == 'true' ]]; then
    NET_CONNECTED='true'
else
    NET_CONNECTED='false'
fi
# ETH_ENABLED='false'
# WIFI_ENABLED='false'
# WIFI_CONNECTED='false'
# NET_CONNECTED='false'
# case "$OSTYPE" in
#     'linux-gnu'*)
#         # Note: /sys/class/net/*/flags = 0x1003 (on) and 0x1002 (off).
#         grep -E '0x1.03' "/sys/class/net/$ETH_IFACE/flags" &>/dev/null && ETH_ENABLED='true'
#         grep -E '0x1.03' "/sys/class/net/$WIFI_IFACE/flags" &>/dev/null && WIFI_ENABLED='true'
#         [[ "$WIFI_ENABLED" = 'true' ]] && ! iw dev "$WIFI_IFACE" link | grep 'Not connected.' &>/dev/null && WIFI_CONNECTED='true'
#         ;;
#     'darwin'*)
#         WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
#         [[ "$WIFI_STATUS" != 'AirPort: Off' ]] && WIFI_ENABLED='true'
#         [[ "$WIFI_ENABLED" = 'true' ]] && [[ "$(<<< "$WIFI_STATUS" awk '/state:/ {print $2}')" != 'init' ]] && WIFI_CONNECTED='true'
#         ;;
# esac

if [[ "$DEBUG" == 'true' ]]; then
    echo "Ethernet enabled:   $ETH_ENABLED"
    echo "Ethernet connected: $ETH_CONNECTED"
    echo "Wi-Fi enabled:      $WIFI_ENABLED"
    echo "Wi-Fi connected:    $WIFI_CONNECTED"
    echo "Network connected:  $NET_CONNECTED"
fi
