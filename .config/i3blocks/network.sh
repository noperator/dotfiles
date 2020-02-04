#!/usr/bin/env bash

# Note: /sys/class/net/*/flags = 0x1003 (on) and 0x1002 (off).

WIFI_IF=$(find /sys/class/net -iname 'wl*' -printf '%f\n')
ETH_IF=$(find /sys/class/net -iname 'en*' -printf '%f\n')
ETH_ENABLED=false
WIFI_ENABLED=false
WIFI_CONNECTED=false
ROUTE_EXISTS=false
VPN_ENABLED=false

# Ethernet enabled?
[[ `grep -E '0x1.03' "/sys/class/net/$ETH_IF/flags"` ]] && ETH_ENABLED=true

# Wi-Fi enabled?
[[ `grep -E '0x1.03' "/sys/class/net/$WIFI_IF/flags"` ]] && WIFI_ENABLED=true

# Wi-Fi connected?
[[ "$WIFI_ENABLED" = 'true' ]] && [[ `iw dev "$WIFI_IF" link | grep 'Not-Associated'` = '' ]] && WIFI_CONNECTED=true

# Route exists?
[[ "$WIFI_CONNECTED" = 'true' ]] || [[ "$ETH_ENABLED" = 'true' ]] && [[ `ip route | grep 'default'` ]] && ROUTE_EXISTS=true

# VPN enabled?
[[ "$ROUTE_EXISTS" = 'true' ]] && [[ `pgrep -ai openvpn` ]] && [[ -e /run/openvpn/run.pid ]] && VPN_ENABLED=true

# echo "Ethernet enabled: $ETH_ENABLED"
# echo "Wi-Fi enabled:    $WIFI_ENABLED"
# echo "Wi-Fi connected:  $WIFI_CONNECTED"
# echo "Route exists:     $ROUTE_EXISTS"
# echo "VPN enabled:      $VPN_ENABLED"
