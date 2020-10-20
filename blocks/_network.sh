#!/bin/bash

if [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    WIFI_IFACE=$(find /sys/class/net -iname 'wl*' -printf '%f\n')
    ETH_IFACE=$(find /sys/class/net -iname 'en*' -printf '%f\n')
fi
source "$(dirname $0)/.env"

ETH_ENABLED='false'
WIFI_ENABLED='false'
WIFI_CONNECTED='false'
# ROUTE_EXISTS=false
# VPN_ENABLED=false

case "$OSTYPE" in
    'linux-gnu'*)
        # Note: /sys/class/net/*/flags = 0x1003 (on) and 0x1002 (off).
        [[ `grep -E '0x1.03' "/sys/class/net/$ETH_IFACE/flags"` ]] && ETH_ENABLED='true'
        [[ `grep -E '0x1.03' "/sys/class/net/$WIFI_IFACE/flags"` ]] && WIFI_ENABLED='true'
        [[ "$WIFI_ENABLED" = 'true' ]] && [[ `iw dev "$WIFI_IFACE" link | grep 'Not-Associated'` = '' ]] && WIFI_CONNECTED='true'
        # [[ "$WIFI_CONNECTED" = 'true' ]] || [[ "$ETH_ENABLED" = 'true' ]] && [[ `ip route | grep 'default'` ]] && ROUTE_EXISTS=true
        # [[ "$ROUTE_EXISTS" = 'true' ]] && [[ `pgrep -ai openvpn` ]] && [[ -e /run/openvpn/run.pid ]] && VPN_ENABLED=true
        ;;
    'darwin'*)
        WIFI_STATUS="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport --getinfo)"
        [[ "$WIFI_STATUS" != 'AirPort: Off' ]] && WIFI_ENABLED='true'
        [[ "$WIFI_ENABLED" = 'true' ]] && [[ "$(<<< "$WIFI_STATUS" awk '/state:/ {print $2}')" != 'init' ]] && WIFI_CONNECTED='true'
        ;;
esac

# echo "Ethernet enabled: $ETH_ENABLED"
# echo "Wi-Fi enabled:    $WIFI_ENABLED"
# echo "Wi-Fi connected:  $WIFI_CONNECTED"
# echo "Route exists:     $ROUTE_EXISTS"
# echo "VPN enabled:      $VPN_ENABLED"
