#!/bin/bash

# PS1
BLK='\[\e[0;30m\]'
RED='\[\e[0;31m\]'
GRN='\[\e[0;32m\]'
YEL='\[\e[0;33m\]'
BLU='\[\e[0;34m\]'
MAG='\[\e[0;35m\]'
CYN='\[\e[0;36m\]'
WHT='\[\e[0;37m\]'
END='\[\e[m\]'                          

# Non-PS1 ("raw")
RBLK='\x01\x1B[0;30m\x02'
RRED='\x01\x1B[0;31m\x02'
RGRN='\x01\x1B[0;32m\x02'
RYEL='\x01\x1B[0;33m\x02'
RBLU='\x01\x1B[0;34m\x02'
RMAG='\x01\x1B[0;35m\x02'
RCYN='\x01\x1B[0;36m\x02'
RWHT='\x01\x1B[0;37m\x02'
REND='\x01\x1B[m\x02'                                 

# Print 256-color test pattern.
# - https://askubuntu.com/a/821163
test_colors() {
    for i in {0..255}; do
        printf '\x1B[48;5;%sm%3d\x1B[0m ' "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i - 15) % 6 == 0 )); then
            printf '\n'
        fi
    done
}
