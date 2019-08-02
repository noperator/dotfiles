#!/bin/sh

OLD_TIME=$(cat '/tmp/geo_time.txt')
NOW=$(date +%s)

if [[ $((NOW - OLD_TIME)) -ge 120 ]]; then
    IP=$(curl -s 'https://api.ipify.org?format=json' | /usr/local/bin/jq -r '.ip')
    IPAPI=$(curl -s "https://ipapi.co/$IP/json/")
    GEO=$(echo "$IPAPI" | /usr/local/bin/jq -r '.city, .region_code' | tr '\n' '\ ')
    ORG=$(echo "$IPAPI" | /usr/local/bin/jq -r '.org' | awk '{print $1}')
    echo "@globe@ $IP $GEO $ORG" > "/tmp/geo_data.txt"
    date +%s > '/tmp/geo_time.txt'
fi

cat '/tmp/geo_data.txt'
