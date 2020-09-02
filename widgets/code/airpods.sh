#!/bin/bash

# Inspiration:
# - https://gist.github.com/Jahhein/45b8e8c9c36a0932189a5037f990bcdd

BT_DEFAULTS=$(defaults read /Library/Preferences/com.apple.Bluetooth)
CONNECTED=$(
    system_profiler SPBluetoothDataType 2>/dev/null |
    grep -E '(AirPods Pro|Connected):' |
    grep -A 1 'AirPods Pro:' |
    awk '/Connected:/ {print $2}'
)

if [[ "$CONNECTED" == 'Yes' ]]; then
    echo '@headphones@'
    for PART in Left Right Case; do
        <<< "$BT_DEFAULTS" awk -v "part=$PART" "/BatteryPercent$PART/"' {
            sub(";", "%", $3);
            if (!(part == "Case" && $3 == "0%"))  # Case disconnected.
                print $3;
        }'
    done
fi
