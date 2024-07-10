#!/usr/bin/env bash

# Font Awesome 5 Free
# https://fontawesome.com/cheatsheet

print_fa_icon() {
    case "$OSTYPE" in
    'linux-gnu'*)
        awk -v "icon=$1" '$2 == icon {printf $1}' "$(dirname $0)/fa-cheat.txt"
        ;;
    'darwin'*)
        # echo -n "@$1@ "
        echo -n "@$1@ "
        ;;
    esac
}
