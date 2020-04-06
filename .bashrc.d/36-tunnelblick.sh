#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    VPN_DIR="$HOME/Library/Application Support/Tunnelblick/Configurations"
    vpnlist() { ls "$VPN_DIR" | sed -E 's/.tblk//g'; }
    vpncommand () {
        osascript \
        -e 'tell application "/Applications/Tunnelblick.app"' \
        -e "$1" \
        -e 'end tell'
    }
    vpnstate () {
        CONFIG_CMD='get state of first configuration where name='
        if [[ $# -eq 0 ]]; then
            for CONFIG in $(vpnlist); do
                echo -n "$CONFIG: "
                vpncommand "$CONFIG_CMD\"$CONFIG\""
            done
        else
            vpncommand "$CONFIG_CMD\"$1\""
        fi
    }
    vpnconfig() {
        PROFILE="$1"
        if [[ -z "$PROFILE" ]]; then
            echo 'Please provide a VPN profile name (see vpnlist).'
            return 1
        fi
        CONFIG="$VPN_DIR/$PROFILE.tblk/Contents/Resources/config.ovpn"
        if [[ -f "$CONFIG" ]]; then
            cat "$CONFIG"
        else
            echo 'VPN profile does not exist.'
        fi
    }
    vpnconnect()    { vpncommand "connect \"$1\""; }
    vpndisconnect() { vpncommand 'disconnect all'; }
fi
