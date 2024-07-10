#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_network.sh"
source "$(dirname $0)/.env"

if [[ "$PUBLIC_IP" == -1 ]]; then
    exit
fi

touch /var/tmp/blocks/public-ip-{time,data}.txt
PATH="/usr/local/bin:$PATH" # Locate jq binary on macOS.

LAST_RUN=$(cat /var/tmp/blocks/public-ip-time.txt)
[[ -z "$LAST_RUN" ]] && LAST_RUN='0'

NOW=$(date +%s)

# Refresh every 2 min.
# TODO:
# - Refresh when private IP changes.
# DIFF=$(diff /var/tmp/blocks/ipv4-hash-*)
#     [[ -n "$DIFF" ]] ||
if [[ -z $(sed -E 's|[/ ]*||g' /var/tmp/blocks/public-ip-data.txt) ]] ||
    [[ "$DEBUG" == 'true' ]] ||
    [[ $((NOW - LAST_RUN)) -ge 120 ]] &&
    [[ ! $(pgrep -f 'curl.*json.myip.wtf') ]]; then

    date +%s >/var/tmp/blocks/public-ip-time.txt

    # Fetch IPv4 data.
    IPV4_DATA=$($(which curl) --connect-timeout 5 -s 'https://ipv4.json.myip.wtf')
    jq <<<"$IPV4_DATA" -r '.YourFuckingIPAddress' >/var/tmp/blocks/ipv4-pub.txt
    IP_V4=$(abbr_ipv4 $(jq <<<"$IPV4_DATA" -r '.YourFuckingIPAddress'))
    # LOC_V4=$(<<< "$IPV4_DATA" jq -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    LOC_V4=$(abbr_str $(jq <<<"$IPV4_DATA" -r '.YourFuckingLocation'))
    ISP_V4=$(abbr_str $(jq <<<"$IPV4_DATA" -r '.YourFuckingISP'))

    # Fetch IPv4 data, while compressing and abbreviating the IP address.
    IPV6_DATA=$($(which curl) --connect-timeout 5 -s 'https://ipv6.json.myip.wtf')
    IP_V6=$(abbr_ipv6 $(jq <<<"$IPV6_DATA" -r '.YourFuckingIPAddress'))
    # LOC_V6=$(jq <<<"$IPV6_DATA" -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    LOC_V6=$(abbr_str $(jq <<<"$IPV6_DATA" -r '.YourFuckingLocation'))
    ISP_V6=$(abbr_str $(jq <<<"$IPV6_DATA" -r '.YourFuckingISP'))

    # echo "$IP_V4 $LOC_V4 $ISP_V4 $IP_V6 $LOC_V6 $ISP_V6" >/var/tmp/blocks/public-ip-data.txt
    # Group matching location and ISP for IPv4 and IPv6, when possible.
    (
        echo -n "$IP_V4 "
        if ! [[ -z "$IP_V6" ]]; then
            if [[ "$LOC_V4" == "$LOC_V6" ]]; then
                # [[ "$ISP_V4" == "$ISP_V6" ]] || echo -n "$ISP_V4 / "
                [[ "$ISP_V4" == "$ISP_V6" ]] || echo -n "$ISP_V4 "
            else
                echo -n "$LOC_V4 "
                [[ "$ISP_V4" == "$ISP_V6" ]] || echo -n "$ISP_V4 "
                # echo -n '/ '
            fi
            echo "$IP_V6 $LOC_V6 $ISP_V6 "
        else
            echo "$LOC_V4 $ISP_V4 "
        fi
    ) >/var/tmp/blocks/public-ip-data.txt
fi

print_fa_icon 'globe'
if [[ "$NET_CONNECTED" == 'false' ]]; then
    echo 'NONE'
    rm /var/tmp/blocks/public-ip-{time,data}.txt
else
    cat /var/tmp/blocks/public-ip-data.txt | sed 's/ $//'
fi

if [[ "$DEBUG" == 'true' ]]; then
    echo "IPv4 address:   \"$IP_V4\""
    echo "IPv4 location:  \"$LOC_V4\""
    echo "IPv4 ISP:       \"$ISP_V4\""
    echo "IPv6 address:   \"$IP_V6\""
    echo "IPv6 location:  \"$LOC_V6\""
    echo "IPv6 ISP:       \"$ISP_V6\""
fi
