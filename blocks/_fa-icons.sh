#!/usr/bin/env bash

# Font Awesome 5 Free
# https://fontawesome.com/cheatsheet

# declare -A FA_ICON=()
declare -A FA_ICON

FA_ICON[ADJUST]=''
FA_ICON[ARROW_UP]=''
FA_ICON[CLOCK]=''
FA_ICON[BATTERY_EMPTY]=''
FA_ICON[BATTERY_FULL]=''
FA_ICON[BATTERY_HALF]=''
FA_ICON[BATTERY_QUARTER]=''
FA_ICON[BATTERY_THREE_QUARTERS]=''
FA_ICON[GLOBE]=''
FA_ICON[PLUG]=''
FA_ICON[VOLUME_DOWN]=''
FA_ICON[VOLUME_MUTE]=''
FA_ICON[VOLUME_OFF]=''
FA_ICON[VOLUME_UP]=''
FA_ICON[WIFI]=''

print_fa_icon()
{
    case "$OSTYPE" in
        'linux-gnu'*)
            ICON_UPPER=$(<<< "$1" tr '[:lower:]' '[:upper:]' | tr '-' '_')
            echo -n "${FA_ICON[$ICON_UPPER]} "
            ;;
        'darwin'*)
            echo -n "@$1@ "
            ;;
    esac
}
