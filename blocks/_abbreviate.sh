#!/bin/bash

abbr_ipv6() {
    if [[ ! -z "$1" ]]; then
        python3 -c "import sys; from ipaddress import ip_address as ip; print(ip(sys.argv[1]).compressed)" "$1" |
            awk -F : '{print $1 "*" $NF}'
    fi
}

abbr_ipv4() {
    if [[ ! -z "$1" ]]; then
        echo "$1" | awk -F . '{print $1 "*" $NF}'
    fi
}

abbr_str() {
    if [[ ! -z "$@" ]]; then
        STR=$(echo "$@" | tr -d ',')
        if [[ $(echo -n "$STR" | wc -c) -le 7 ]]; then
            echo "$STR"
        else
            echo "$STR" | awk '{printf substr($0, 0, 6) "…"}'
        fi
    fi
}
