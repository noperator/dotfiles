#!/bin/bash

# PS1="${BYEL}\W${END} ${BCYN}$(printf '\xf0\x9d\x84\xa2')${END} "
# PS1="${BGRN}\u${END}${BBLU}@${END}${BRED}$(hostname -f) ${END}${BYEL}\W${END} ${BCYN}\m${END} "
PS1="${CYN}\u${END}${GRN}@${END}${PRP}$(hostname -f)${END}${GRN}:${END}${YEL}\W${END} ${RED}$(printf '\xf0\x9d\x84\xa2')${END} "
PS2="${BCYN}$(printf '\xe2\x80\xa6')${END} "
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
