#!/bin/bash

source "$(dirname $0)/_check-bt.sh"

if [[ $(bluetooth_device_connected 'Trackpad') == 'Yes' ]]; then
    echo '@mouse-pointer@'
    defaults read /Library/Preferences/com.apple.Bluetooth |
    grep -E 'BatteryPercent =|Name = .*Trackpad' |
    grep -A 1 'displayName' |
    awk '/BatteryPercent/ {
        gsub(/"/, "", $3);
        sub(";", "", $3);
        $3 = $3 * 100;
        print $3 "%";
    }';
fi
