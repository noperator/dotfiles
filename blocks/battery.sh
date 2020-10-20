#!/bin/bash

SOURCE=''
case "$OSTYPE" in
    'linux-gnu'*)
        PERCENT=$(acpi -b | awk '{s += $4; i += 1} END {print int(s/i)}')
        if acpi -a | grep 'on-line' &>/dev/null; then
            SOURCE='AC'
            ICON='⚡'
        else
            ICON='🔋'
        fi
        ;;
    'darwin'*)
        BATTERY=$(pmset -g batt)
        PERCENT=$(<<< "$BATTERY" grep -oE '\d*%' | tr -d '%')
        SOURCE=$(<<< "$BATTERY" tr -d "'" | awk '/Now drawing from/ {print $4}')

        if [[ "$SOURCE" == 'AC' ]]; then
            ICON='@plug@'
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
            ICON="@battery-$LVL@"
        fi
        ;;
esac

# Don't print battery status if laptop is plugged in and fully charged.
if [[ "$PERCENT" -eq '100' ]] && [[ "$SOURCE" == 'AC' ]]; then
    exit
else
    echo "$ICON $PERCENT%"
fi
