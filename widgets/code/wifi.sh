#!/bin/bash

source "$(dirname $0)/abbr-ipv6.sh"

IFACE='en0'

WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"

echo -n '@wifi@ '
if [[ "$WIFI_STATUS" == 'AirPort: Off' ]]; then
    echo 'OFF'
elif [[ "$(<<< "$WIFI_STATUS" awk '/state:/ {print $2}')" == 'init' ]]; then
    echo 'NONE'
else
    SIGNAL=$(<<< "$WIFI_STATUS" awk '/agrCtlRSSI/ {print $NF}')
    if [[ "$SIGNAL" -le -100 ]]; then
        QUALITY=0
    elif [[ "$SIGNAL" -ge -50 ]]; then
        QUALITY=100
    else
        QUALITY=$(echo "2 * ($SIGNAL + 100)" | bc -l)
    fi
    SSID=$(<<< "$WIFI_STATUS" awk '/[^B]SSID/ {print substr($NF, 0, 6) "…"}')
    IPV4=$(ifconfig "$IFACE" inet | awk '/inet/ {print $2}')
    IPV6=$(abbr_ipv6 $(ifconfig "$IFACE" inet6 | awk '{if ($6 == "temporary" && ! match($2, "^f[cd]")) print $2}'))
    echo "$IPV4 $IPV6 $SSID ${QUALITY}%"
fi
