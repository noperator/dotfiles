#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"

# Convert Wi-Fi signal strength RSSI dBm to percentage.
# - https://stackoverflow.com/a/15798024
# @param $1 Signal strength in dBm.
# @return <PERCENTAGE>
dbm_to_percent() {
    if [[ "$1" -le -100 ]]; then
        echo '0'
    elif [[ "$1" -ge -50 ]]; then
        echo '100'
    else
        echo "2 * ($1 + 100)" | bc -l
    fi
}

# Get Wi-Fi connection information.
# @param $1 Wi-Fi interface.
# @return <SSID> <SIGNAL-DBM>
get_wifi_info() {
    case "$OSTYPE" in
    'linux-gnu'*)
        iw dev "$1" link | awk '/SSID:/ {printf substr($2, 0, 6) "… "}'
        awk -v "iface=$1" '$1 == iface {print $4}' /proc/net/wireless
        ;;
    'darwin'*)
        WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
        awk '/[^B]SSID/ {sub(/.*: /, "", $0); printf substr($0, 0, 6)}' <<<"$WIFI_STATUS" | tr ' ' ' '
        echo -n '… '
        awk <<<"$WIFI_STATUS" '/agrCtlRSSI/ {print $NF}'
        ;;
    esac
}

print_fa_icon 'wifi'
if [[ "$WIFI_ENABLED" == 'false' ]]; then
    echo 'OFF'
elif [[ "$WIFI_CONNECTED" == 'false' ]]; then
    echo 'NONE'
else
    get_iface_ipv4 "$WIFI_IFACE" >/var/tmp/blocks/ipv4-wif.txt
    IPV4=$(abbr_ipv4 $(get_iface_ipv4 "$WIFI_IFACE"))
    IPV6=$(abbr_ipv6 $(get_iface_ipv6 "$WIFI_IFACE"))
    WIFI_INFO=$(get_wifi_info "$WIFI_IFACE")
    SSID=$(awk <<<"$WIFI_INFO" '{print $1}')
    SIGNAL=$(awk <<<"$WIFI_INFO" '{print $2}')
    QUALITY=$(dbm_to_percent "$SIGNAL")%
    BSSID=$(cat /var/tmp/blocks/bssid.txt)
    OUI=$(echo "$BSSID" | tr : '\n' | head -n 3 | xargs printf "%02s" | tr '[:lower:]' '[:upper:]')
    VENDOR=$(abbr_str $(get_vendor "$OUI"))
    for VAR in IPV4 IPV6 SSID QUALITY VENDOR; do
        if [[ -n ${!VAR} ]]; then
            echo -n "${!VAR} " | tr ' ' ' '
        fi
    done
fi
