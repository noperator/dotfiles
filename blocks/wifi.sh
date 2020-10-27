#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_abbr-ipv6.sh"
source "$(dirname $0)/_network.sh"
source "$(dirname $0)/.env"

# WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"

print_fa_icon 'wifi'
if [[ "$WIFI_ENABLED" == 'false' ]]; then
    echo 'OFF'
elif [[ "$WIFI_CONNECTED" == 'false' ]]; then
    echo 'NONE'
else
    case "$OSTYPE" in
        'linux-gnu'*)
            IPV4=$(ip -4 addr show "$WIFI_IFACE" | perl -n -e "/inet ([^\/]+).* scope global/ && print \$1 and exit")
            IPV6=$(abbr_ipv6 $(ip -6 addr show "$WIFI_IFACE" | grep -B 1 'sec' | awk 'NR == 1 {sub(/\/.*/, "", $2); print $2}'))
            SSID=$(iw dev "$WIFI_IFACE" link | awk '/SSID:/ {print substr ($2, 0, 6) "…"}')
            QUALITY=$(grep "$WIFI_IFACE" /proc/net/wireless | awk '{print int($3 * 100 / 70)}')
            ;;
        'darwin'*)
            SIGNAL=$(<<< "$WIFI_STATUS" awk '/agrCtlRSSI/ {print $NF}')
            if [[ "$SIGNAL" -le -100 ]]; then
                QUALITY=0
            elif [[ "$SIGNAL" -ge -50 ]]; then
                QUALITY=100
            else
                QUALITY=$(echo "2 * ($SIGNAL + 100)" | bc -l)
            fi
            SSID=$(<<< "$WIFI_STATUS" awk '/[^B]SSID/ {print substr($NF, 0, 6) "…"}')
            IPV4=$(ifconfig "$WIFI_IFACE" inet | awk '/inet/ {print $2}')
            IPV6=$(abbr_ipv6 $(ifconfig "$WIFI_IFACE" inet6 | awk '{if ($6 == "temporary" && ! match($2, "^f[cd]")) print $2}'))
            ;;
    esac
    # if [[ -z "$SSID" ]]; then
    #     echo 'DISCONNECTED'
    # else
    echo "$IPV4 $IPV6 $SSID $QUALITY%"
    # fi
fi
