#!/bin/sh

BATTERY=$(pmset -g batt)

PERCENT=$(echo "$BATTERY" | grep -oE '\d*%' | tr -d '%')

SOURCE=$(echo "$BATTERY" | grep -oE "'.*?'" | sed -E "s/'(.*) Power'/\1/")

if [[ "$SOURCE" == 'AC' ]]; then
    ICON='plug'
else
    if [[ "$PERCENT" -lt 10 ]]; then
        LVL='empty'
    elif [[ "$PERCENT" -lt 35 ]]; then
        LVL='quarter'
    elif [[ "$PERCENT" -lt 65 ]]; then
        LVL='half'
    elif [[ "$PERCENT" -lt 90 ]]; then
        LVL='three-quarters'
    else
        LVL='full'
    fi
    ICON="battery-$LVL"
fi

echo "@${ICON}@ ${PERCENT}%"
