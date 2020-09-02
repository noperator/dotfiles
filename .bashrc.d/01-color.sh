#!/bin/bash

# PS1
BLK='\[\e[0;30m\]' ; BBLK='\[\e[1;30m\]'
RED='\[\e[0;31m\]' ; BRED='\[\e[1;31m\]'
GRN='\[\e[0;32m\]' ; BGRN='\[\e[1;32m\]'
YEL='\[\e[0;33m\]' ; BYEL='\[\e[1;33m\]'
BLU='\[\e[0;34m\]' ; BBLU='\[\e[1;34m\]'
PRP='\[\e[0;35m\]' ; BPRP='\[\e[1;35m\]'
CYN='\[\e[0;36m\]' ; BCYN='\[\e[1;36m\]'
GRY='\[\e[0;37m\]' ; BGRY='\[\e[1;37m\]'
END='\[\e[m\]'                          

# Non-PS1
RBLK='\x01\x1B[0;30m\x02' ; RBBLK='\x01\x1B[1;30m\x02'
RRED='\x01\x1B[0;31m\x02' ; RBRED='\x01\x1B[1;31m\x02'
RGRN='\x01\x1B[0;32m\x02' ; RBGRN='\x01\x1B[1;32m\x02'
RYEL='\x01\x1B[0;33m\x02' ; RBYEL='\x01\x1B[1;33m\x02'
RBLU='\x01\x1B[0;34m\x02' ; RBBLU='\x01\x1B[1;34m\x02'
RPRP='\x01\x1B[0;35m\x02' ; RBPRP='\x01\x1B[1;35m\x02'
RCYN='\x01\x1B[0;36m\x02' ; RBCYN='\x01\x1B[1;36m\x02'
RGRY='\x01\x1B[0;37m\x02' ; RBGRY='\x01\x1B[1;37m\x02'
REND='\x01\x1B[m\x02'                                 

# Print 256-color test pattern.
# - https://askubuntu.com/a/821163
test_colors() {
    for i in {0..255}; do
        printf '\x1b[48;5;%sm%3d\e[0m ' "$i" "$i"
        if (( i == 15 )) || (( i > 15 )) && (( (i - 15) % 6 == 0 )); then
            printf '\n'
        fi
    done
}
