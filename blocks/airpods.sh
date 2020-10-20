#!/bin/bash

source "$(dirname $0)/_check-bt.sh"

BT_DEFAULTS=$(defaults read /Library/Preferences/com.apple.Bluetooth)
if [[ $(bluetooth_device_connected 'AirPods Pro') == 'Yes' ]]; then
    echo '@headphones@'
    for PART in Left Right Case; do
        <<< "$BT_DEFAULTS" awk -v "part=$PART" "/BatteryPercent$PART/"' {
            sub(";", "%", $3);
            if (!(part == "Case" && $3 == "0%"))  # Case disconnected.
                print $3;
        }'
    done
fi
