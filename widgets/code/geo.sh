#!/bin/bash

source "$(dirname $0)/abbr_ipv6.sh"

touch /var/tmp/geo_time.txt /var/tmp/geo_data.txt
PATH="/usr/local/bin:$PATH"  # Locate jq binary.

OLD_TIME=$(cat /var/tmp/geo_time.txt)
NOW=$(date +%s)

# Refresh every 2 min.
if [[ $(sed -E 's|[/ ]||g' /var/tmp/geo_data.txt) == '@globe@' ]] ||
   [[ $((NOW - OLD_TIME)) -ge 120 ]] &&
   [[ ! $(pgrep -f 'curl.*json.wtfismyip.com') ]]; then

    # Fetch IPv4 data.
    IPV4=$(curl -s 'ipv4.json.wtfismyip.com')
    IP_V4=$(<<< "$IPV4" jq -r '.YourFuckingIPAddress')
    LOC_V4=$(<<< "$IPV4" jq -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    ISP_V4=$(<<< "$IPV4" jq -r '.YourFuckingISP' | awk '{print $1}')

    # Fetch IPv4 data, while compressing and abbreviating the IP address.
    IPV6=$(curl -s 'ipv6.json.wtfismyip.com')
    IP_V6=$(abbr_ipv6 $(<<< "$IPV6" jq -r '.YourFuckingIPAddress'))
    # IP_V6=$(python3 -c "from ipaddress import ip_address as ip; print(ip('$IP_V6').compressed)" |
    #         sed -E 's/^(.{7}).*(.{7})$/\1*\2/')
    LOC_V6=$(<<< "$IPV6" jq -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    ISP_V6=$(<<< "$IPV6" jq -r '.YourFuckingISP' | awk '{print $1}')

    # Group matching location and ISP for IPv4 and IPv6, when possible.
    (
    echo -n '@globe@ '
    echo -n "$IP_V4 "
    if ! [[ -z "$IP_V6" ]]; then
        if [[ "$LOC_V4" == "$LOC_V6" ]]; then
            [[ "$ISP_V4" == "$ISP_V6" ]] || echo -n "$ISP_V4 / "
        else
            echo -n "$LOC_V4 "
            [[ "$ISP_V4" == "$ISP_V6" ]] || echo -n "$ISP_V4 "
            echo -n '/ '
        fi
        echo "$IP_V6 $LOC_V6 $ISP_V6 "
    else
        echo "$LOC_V4 $ISP_V4 "
    fi
    ) > /var/tmp/geo_data.txt

    date +%s > /var/tmp/geo_time.txt
fi

cat /var/tmp/geo_data.txt
