#!/bin/bash

# Less efficient way to check if shell is local.
# if [[ $(awk -F = '/^ID/ {print $2}' /etc/os-release 2>/dev/null) == 'arch' ]] || \
#    [[ "$OSTYPE" == 'darwin'* ]]; then

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')
if [[ $(tty) == *'tty'* ]]; then
    PS1="${BYEL}\w${END} ${BCYN}\$${END} "
    PS2="${BCYN}>${END} "
else
    PS2="${BCYN}$ELLIPSIS${END} "
    if [[ -v SSH_TTY ]]; then
        PS1="${CYN}\u${END}${GRN}@${END}${PRP}\h${END}${GRN}:${END}${YEL}\W${END} ${RED}${BASS_CLEF}${END} "
    else
        PS1="${BYEL}\W${END} ${BCYN}${BASS_CLEF}${END} "
    fi
fi

PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
