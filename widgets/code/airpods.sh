#!/bin/bash

# Inspiration:
# - https://gist.github.com/Jahhein/45b8e8c9c36a0932189a5037f990bcdd

BT_DEFAULTS=$(defaults read /Library/Preferences/com.apple.Bluetooth)

# MAC_ADDR=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -A 1 'AirPods Pro' | awk '/Address:/ {print $2}')
CONNECTED=$(
    system_profiler SPBluetoothDataType 2>/dev/null |
    grep -E '(AirPods Pro|Connected):' |
    grep -A 1 'AirPods Pro:' |
    awk '/Connected:/ {print $2}'
)

echo '@headphones@'
if [[ "$CONNECTED" == 'Yes' ]]; then
    for EAR in Left Right; do
        <<< "$BT_DEFAULTS" awk "/BatteryPercent$EAR/"' {sub(";", "%", $3); print $3}'

        # PERCENT=$(<<< "$BT_DEFAULTS" awk "/BatteryPercent$EAR/"' {sub(";", "", $3); print $3}')
        # if   [[ "$PERCENT" -lt 10 ]]; then
        #     LVL='empty'
        # elif [[ "$PERCENT" -lt 35 ]]; then
        #     LVL='quarter'
        # elif [[ "$PERCENT" -lt 65 ]]; then
        #     LVL='half'
        # elif [[ "$PERCENT" -lt 90 ]]; then
        #     LVL='three-quarters'
        # else
        #     LVL='full'
        # fi
        # echo "@battery-$LVL@ "

    done
fi
