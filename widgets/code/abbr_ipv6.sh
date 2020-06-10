#!/bin/bash

# Compress and abbreviate an IPv6 address to be displayed in a status bar.
abbr_ipv6() {
    python3 -c "from ipaddress import ip_address as ip; print(ip('$1').compressed)" |
    sed -E 's/^(.{7}).*(.{7})$/\1*\2/'
}
