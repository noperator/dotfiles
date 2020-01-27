#!/bin/bash

if [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    # Socket statistics.
    alias snb="{ ss -Hantup4; ss -Hantup6; } | awk '{print \$1,\$2,\$5,\$6,\$7}' | sed -E 's/users:\(\(\"|,fd=.*//g ; s/\",pid=/\//g' | column -t | sort -k 5"
    alias sn="snb | cut -c -$COLUMNS"
    alias sne="snb | grep 'ESTAB' | column -t | cut -c -$COLUMNS"
    alias snl="snb | vg 'ESTAB|CLOSE-WAIT|LAST-ACK|TIME-WAIT|SYN-SENT|FIN-WAIT' | column -t | cut -c -$COLUMNS"
    alias snu="snb | grep '^udp' | column -t | cut -c -$COLUMNS"

    alias netctl='sudo /usr/bin/netctl'
    alias nsa='netctl stop-all'
    alias ns='netctl start'
    nsn() { nsa; ns "$(ncl | head -n $1 | tail -n 1 | awk '{print $NF}')"; }
    alias ncl='/usr/bin/netctl list | grep -n "" | column -t -s :'
    alias wm="sudo wifi-menu"

    pgw() { ping `ip route | awk '$1 == "default" {print $3}'`; }

    bt() { echo "power $@" | bluetoothctl; (sleep 1; ri3b_bt;) & }
fi

case "$OSTYPE" in 
    'linux-gnu'*)
        ping() { "$(which ping)" -c 1 -w 2 "$@" | grep 'bytes from' || echo "No reply from $@."; }
        ;;
    'darwin'*)
        ping() { "$(which ping)" -c 1 -W 2000 "$@" | grep 'bytes from' || echo "No reply from $@."; }
        pgw () { ping "$(netstat -f inet -nr | awk '/default/ {print $2}')"; }
        ;;
esac

alias png='ping google.com'
arping() { "$(which arping)" -c 1 "$@" | g 'bytes from' || echo "No reply from $@."; }
geo() { curl -s "https://ipapi.co/$@/json/"; }
alias c='curl -skA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:68.0) Gecko/20100101 Firefox/68.0"'
syn() { sudo nmap -oG - -Pn -sS -p "$2" "$1" | grep -oE 'Ports:.*'; }
alias dg='dig @8.8.8.8 +short google.com'
