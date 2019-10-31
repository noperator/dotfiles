#!/bin/bash

if [[ "$OSTYPE" == 'darwin'* ]]; then
    VPN_DIR="$HOME/Library/Application\ Support/Tunnelblick/Configurations"
    alias vpnlist='ls '"$VPN_DIR"" | sed -E 's/.tblk//g'"
    vpncommand () {
      osascript -e "tell application \"/Applications/Tunnelblick.app\"" \
      -e "$1" -e "end tell"
    }
    vpnstate () {
      if [[ $# -eq 0 ]]; then
        for c in `vpnlist`; do
          echo -n "$c: "
          vpncommand "get state of first configuration where name=\"$c\""
        done
      else
        vpncommand "get state of first configuration where name=\"$1\""
      fi | sed ''/CONNECTED/s//`printf "${grn}CONNECTED${end}"`/'' | \
      sed ''/EXITING/s//`printf "${red}EXITING${end}"`/''
    }
    vpnconfig() {
      CONFIG="$VPN_DIR/${1}.tblk/Contents/Resources/config.ovpn"
      if [[ -f "$CONFIG" ]]; then sudo cat "$CONFIG"
      else echo "VPN profile does not exist."; fi
    }
    vpnremote() { vpnconfig "$1" | grep remote | awk '{print $2}'; }
    vpnconnect() { vpncommand "connect \"$1\""; }
    vpndisconnect() { vpncommand "disconnect all"; }
    vpncheck() {
      if [[ `vpnstate "$1" | grep "CONNECTED"` ]]; then
        [[ -z "$2" ]] && VPNIP=$( vpnremote "$1" ) || VPNIP="$2"
        MYIP=$( curl -s https://api.ipify.org )
        if [[ "$VPNIP" = "$MYIP" ]]; then
          printf "\xe2\x9c\x93 %s" "${grn}VPN is working.${end}";
        else
          printf "\xe2\x9c\x97 %s%s%s" "${red}VPN NOT WORKING" '!' "${end}";
        fi;
      else printf '\xe2\x80\x93 VPN disconnected.'; fi;
    }
fi
