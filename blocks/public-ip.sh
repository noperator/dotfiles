#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"
source "$(dirname $0)/_abbr-ipv6.sh"
source "$(dirname $0)/_network.sh"

touch /var/tmp/public-ip-{time,data}.txt
PATH="/usr/local/bin:$PATH"  # Locate jq binary on macOS.

LAST_RUN=$(cat /var/tmp/public-ip-time.txt)
[[ -z "$LAST_RUN" ]] && LAST_RUN='0'

NOW=$(date +%s)

# Refresh every 2 min.
if [[ -z $(sed -E 's|[/ ]*||g' /var/tmp/public-ip-data.txt) ]] ||
   [[ $((NOW - LAST_RUN)) -ge 120 ]] &&
   [[ ! $(pgrep -f 'curl.*json.wtfismyip.com') ]]; then

    date +%s > /var/tmp/public-ip-time.txt

    # Fetch IPv4 data.
    IPV4_DATA=$(curl --connect-timeout 5 -s 'ipv4.json.wtfismyip.com')
    IP_V4=$(<<< "$IPV4_DATA" jq -r '.YourFuckingIPAddress')
    LOC_V4=$(<<< "$IPV4_DATA" jq -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    ISP_V4=$(<<< "$IPV4_DATA" jq -r '.YourFuckingISP' | awk '{print $1}')

    # Fetch IPv4 data, while compressing and abbreviating the IP address.
    IPV6_DATA=$(curl --connect-timeout 5 -s 'ipv6.json.wtfismyip.com')
    IP_V6=$(abbr_ipv6 $(<<< "$IPV6_DATA" jq -r '.YourFuckingIPAddress'))
    LOC_V6=$(<<< "$IPV6_DATA" jq -r '.YourFuckingLocation' | awk -F ',' '{print $1 $2}')
    ISP_V6=$(<<< "$IPV6_DATA" jq -r '.YourFuckingISP' | awk '{print $1}')

    # Group matching location and ISP for IPv4 and IPv6, when possible.
    (
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
    ) > /var/tmp/public-ip-data.txt
fi

print_fa_icon 'globe'
[[ "$WIFI_CONNECTED" == 'false' ]] && (echo; exit)
cat /var/tmp/public-ip-data.txt | sed 's/ $//'
