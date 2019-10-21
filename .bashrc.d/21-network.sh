#!/bin/bash

if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    alias sn="sudo ss -antup | tail -n +2 | awk '{print \$1,\$2,\$5,\$6,\$7}' | sed -E 's/users:\(\(\"|,fd=.*//g ; s/\",pid=/\//g' | column -t | sort -k 5 | cut -c -\$COLUMNS"
    alias sne="sn | grep 'ESTAB' | column -t"
    alias snl="sn | grep -vE 'ESTAB|CLOSE-WAIT|LAST-ACK|TIME-WAIT|SYN-SENT' | column -t"
    alias snu="sn | grep '^udp' | column -t"
fi

case "$OSTYPE" in 
    'linux-gnu')
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
