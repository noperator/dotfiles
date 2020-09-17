#!/bin/bash

# Inspiration:
# - https://gist.github.com/Jahhein/45b8e8c9c36a0932189a5037f990bcdd

bluetooth_device_connected() {
    DEVICE="$1"
    system_profiler SPBluetoothDataType 2>/dev/null |
    grep -E "($DEVICE|Connected):" |
    grep -A 1 "$DEVICE:" |
    awk '/Connected:/ {print $2}'
}
