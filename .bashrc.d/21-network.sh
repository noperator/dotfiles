#!/bin/bash

if which dog &>/dev/null; then
    alias dig='dog'
fi

if [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    # Socket statistics.
    alias snb="{ sudo ss -Hantup4; sudo ss -Hantup6; } | awk '{print \$1,\$2,\$5,\$6,\$7}' | sed -E 's/users:\(\(\"|,fd=.*//g ; s/\",pid=/\//g' | column -t | sort -k 5"
    alias sn="snb | cut -c -\$COLUMNS"
    alias sne="snb | grep 'ESTAB' | column -t | cut -c -\$COLUMNS"
    alias snl="snb | vg 'ESTAB|CLOSE-WAIT|LAST-ACK|TIME-WAIT|SYN-SENT|FIN-WAIT' | column -t | cut -c -\$COLUMNS"
    alias snu="snb | grep '^udp' | column -t | cut -c -\$COLUMNS"

    # Network profiles.
    nsa() { sudo $(which netctl) stop-all; }
    ns() { sudo $(which netctl) start "$@"; }
    ncl() { netctl list | nl -s ' ' -w 2; }
    nsn() {
        nsa
        ns "$(ncl | head -n $1 | tail -n 1 | awk '{print $NF}')"
    }
    alias wm="sudo wifi-menu"

    # Firewall.
    alias ufw="sudo $(which ufw 2>/dev/null)"
    alias us='ufw status numbered'
    alias ua='ufw allow'
    alias ud='ufw delete'

    # Misc.
    pgw() { ping $(ip route | awk '$1 == "default" {print $3}'); }
    bt() {
        echo "power $@" | bluetoothctl
        (
            sleep 1
            ri3b_bt
        ) &
    }
fi

case "$OSTYPE" in
'linux-gnu'*)
    ping() { "$(which ping)" -c 1 -w 2 "$@" | grep 'bytes from' || echo "No reply from $@."; }
    ;;
'darwin'*)
    ping() { "$(which ping)" -c 1 -W 2000 "$@" | grep 'bytes from' || echo "No reply from $@."; }
    pgw() { ping "$(netstat -f inet -nr | awk '/default/ {print $2}')"; }
    ;;
esac

alias png='ping google.com'
arping() { "$(which arping)" -c 1 "$@" | g 'bytes from' || echo "No reply from $@."; }
geo() { curl -s "https://ipapi.co/$@/json/"; }
alias c='curl -skA "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:68.0) Gecko/20100101 Firefox/68.0"'
syn() { sudo nmap -oG - -Pn -sS -p "$2" "$1" | grep -oE 'Ports:.*'; }
alias dg='dig @8.8.8.8 google.com'
sshc() {
    ssh -G "$1" | grep -E '^(user|hostname|port|identityfile) '
}
