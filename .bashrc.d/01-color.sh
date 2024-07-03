#!/bin/bash

declare -A CLR
CLR[BLK]='\x01\x1B[0;30m\x02'
CLR[RED]='\x01\x1B[0;31m\x02'
CLR[GRN]='\x01\x1B[0;32m\x02'
CLR[YEL]='\x01\x1B[0;33m\x02'
CLR[BLU]='\x01\x1B[0;34m\x02'
CLR[MAG]='\x01\x1B[0;35m\x02'
CLR[CYN]='\x01\x1B[0;36m\x02'
CLR[WHT]='\x01\x1B[0;37m\x02'
CLR[BBL]='\x01\x1B[0;90m\x02'
CLR[BRE]='\x01\x1B[0;91m\x02'
CLR[BGR]='\x01\x1B[0;92m\x02'
CLR[BYE]='\x01\x1B[0;93m\x02'
CLR[BBL]='\x01\x1B[0;94m\x02'
CLR[BMA]='\x01\x1B[0;95m\x02'
CLR[BCY]='\x01\x1B[0;96m\x02'
CLR[BWH]='\x01\x1B[0;97m\x02'
CLR[END]='\x01\x1B[m\x02'

# Create separate array for prompt string colors.
declare -A PS_CLR
for COLOR in "${!CLR[@]}"; do
    declare "PS_CLR[$COLOR]"=$(
        echo -ne "${CLR[$COLOR]}" |
            perl -pe 's/\x01/\\[/; s/\x1B/\\e/; s/\x02/\\]/'
    )
done

# Print 256-color test pattern.
# - https://askubuntu.com/a/821163
test_colors() {
    for i in {0..255}; do
        printf '\x1B[48;5;%sm%3d\x1B[0m ' "$i" "$i"
        if ((i == 15)) || ((i > 15)) && (((i - 15) % 6 == 0)); then
            printf '\n'
        fi
    done
}
