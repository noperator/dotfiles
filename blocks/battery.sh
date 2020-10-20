#!/usr/bin/env bash

source "$(dirname $0)/_fa-icons.sh"

SOURCE=''
case "$OSTYPE" in
    'linux-gnu'*)
        PERCENT=$(acpi -b | awk '{s += $4; i += 1} END {print int(s/i)}')
        acpi -a | grep 'on-line' &>/dev/null && SOURCE='AC'
        ;;
    'darwin'*)
        BATTERY=$(pmset -g batt)
        PERCENT=$(<<< "$BATTERY" grep -oE '\d*%' | tr -d '%')
        SOURCE=$(<<< "$BATTERY" tr -d "'" | awk '/Now drawing from/ {print $4}')
        ;;
esac

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

# Don't print battery status if laptop is plugged in and fully charged.
if ! [[ "$PERCENT" -eq '100' ]] && [[ "$SOURCE" == 'AC' ]]; then
    exit
else
    print_fa_icon "$ICON"
    echo "$PERCENT%"
fi
