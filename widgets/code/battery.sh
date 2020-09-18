#!/bin/bash

BATTERY=$(pmset -g batt)
PERCENT=$(<<< "$BATTERY" grep -oE '\d*%' | tr -d '%')
SOURCE=$(<<< "$BATTERY" tr -d "'" | awk '/Now drawing from/ {print $4}')

# Don't print battery status if laptop is plugged in and fully charged.
[[ "$PERCENT" -eq '100' ]] && [[ "$SOURCE" == 'AC' ]] && exit

if [[ "$SOURCE" == 'AC' ]]; then
    ICON='plug'
else
    if   [[ "$PERCENT" -lt 10 ]]; then
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
