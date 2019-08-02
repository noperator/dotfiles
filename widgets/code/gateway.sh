#!/bin/bash

echo -n "@arrow-up@ "

DIRNAME=$(dirname "$0")
# GATEWAY=$(route get default | awk '/gateway/ {print $NF}')
GATEWAY=$(netstat -f inet -nr | awk '/default/ {print $2}')

if [[ -z "$GATEWAY" ]]; then
    echo 'NONE'
else
    if ! [[ -z "$GATEWAY" ]]; then
        MAC=$(arp -an | awk "/\($GATEWAY\)/ {print \$4}" | sed -E 's/^(([0-9a-f]{1,2}:){3}).*/\1/' | tr -d ':')
        VENDOR=$(grep -i "$MAC" "$DIRNAME/oui.txt" | cut -f 3- | sed 's/,.*//' | awk '{print $1}')
        # VENDOR=$(grep -i "$MAC" '/usr/local/share/nmap/nmap-mac-prefixes' | cut -d ' ' -f 2- | sed 's/,.*//')
    fi
    echo "$GATEWAY $VENDOR"
fi

