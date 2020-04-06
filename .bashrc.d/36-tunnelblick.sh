#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    VPN_DIR="$HOME/Library/Application Support/Tunnelblick/Configurations"
    alias vpnlist="ls \"$VPN_DIR\" | sed -E 's/.tblk//g'"
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
    vpncheck() {
        if [[ $(vpnstate "$1" | grep 'CONNECTED') ]]; then
            if [[ -z "$2" ]]; then
                VPNIP=$(vpnconfig "$1" | grep remote | awk '{print $2}')
            else
                VPNIP="$2"
            fi
            MYIP=$(curl -s https://api.ipify.org)
            if [[ "$VPNIP" = "$MYIP" ]]; then
                printf "\xe2\x9c\x93 %s" "${grn}VPN is working.${end}";
            else
                printf "\xe2\x9c\x97 %s%s%s" "${red}VPN NOT WORKING" '!' "${end}";
            fi
        else
            printf '\xe2\x80\x93 VPN disconnected.'
        fi
    }
fi
