#!/bin/bash

# echo -n "@$(basename "$0" | sed -E 's/.{3}$//')@ "
echo -n '@wifi@ '

INFO="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"

if [[ "$INFO" == 'AirPort: Off' ]]; then
    echo "OFF"
elif [[ "$(echo "$INFO" | awk '/state:/ {print $2}')" == 'init' ]]; then
    echo "NONE"
else
    DBM=$(echo "$INFO" | awk '/agrCtlRSSI/ {print $NF}')
    if [[ "$DBM" -le -100 ]]; then
        QUALITY=0
    elif [[ "$DBM" -ge -50 ]]; then
        QUALITY=100
    else
        QUALITY=$(echo "2 * ($DBM + 100)" | bc -l)
    fi
    SSID=$(echo "$INFO" | awk '/[^B]SSID/ {print $NF}')
    IP=$(ifconfig en0 inet | awk '/inet/ {print $2}')
    echo "$IP $SSID ${QUALITY}%"
fi


