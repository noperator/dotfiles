#!/bin/bash

touch /var/tmp/geo_time.txt /var/tmp/geo_data.txt

OLD_TIME=$(cat /var/tmp/geo_time.txt)
NOW=$(date +%s)

if [[ $(cat /var/tmp/geo_data.txt) == '@globe@' ]] || [[ $((NOW - OLD_TIME)) -ge 120 ]]; then
    IP=$(curl -s 'https://api.ipify.org?format=json' | /usr/local/bin/jq -r '.ip')
    OLD_IP=$(awk '{print $2}' /var/tmp/geo_data.txt)
    if [[ "$IP" != "$OLD_IP" ]]; then
        IPAPI=$(curl -s "https://ipapi.co/$IP/json/")
        GEO=$(echo "$IPAPI" | /usr/local/bin/jq -r '.city, .region_code' | tr '\n' '\ ')
        ORG=$(echo "$IPAPI" | /usr/local/bin/jq -r '.org' | awk '{print $1}' | tr -d ',')
        echo "@globe@ $IP $GEO $ORG" > /var/tmp/geo_data.txt
    fi
    date +%s > /var/tmp/geo_time.txt
fi

cat /var/tmp/geo_data.txt
