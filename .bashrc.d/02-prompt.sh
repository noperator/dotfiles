#!/bin/bash

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')

# Print color-coded, abbreviated Git branch.
git_branch() {
    BRANCH=$(git branch 2> /dev/null |
             awk -v "ellipsis=$ELLIPSIS" '{
                 if ($1 == "*") {
                     printf substr($2, 0, 6);
                     if (length($2) > 6)
                         print ellipsis
                 }
             }')
    if [[ "$BRANCH" ]]; then

        # Setting colors according to a Stack Overflow post:
        # https://stackoverflow.com/a/43462720
        if [[ $(git status | grep -E '^Your branch is up to date with') ]]; then
            echo -ne '\001\e[0;32m\002'  # Print up-to-date branch in green.
        else
            echo -ne '\001\e[0;31m\002'  # Print outdated branch in red.
        fi
        echo -n " $BRANCH"
        echo -ne '\001\e[m\002'
    fi
}

# Set Bash prompt according to terminal type and location.
if [[ $(tty | grep -E 'tty[^s]' ) ]]; then

    # Native terminal device, and likely no Unicode support.
    PS1="${BYEL}\w${END}\$(git_branch) ${BCYN}\$${END} "
    PS2="${BCYN}>${END} "
else

    # Pseudo terminal device.
    PS2="${BCYN}$ELLIPSIS${END} "
    if [[ -v SSH_TTY ]]; then

        # Remote server.
        PS1="${CYN}\u${END}${GRN}@${END}${PRP}\h${END}${GRN}:${END}${YEL}\W${END}\$(git_branch) ${RED}${BASS_CLEF}${END} "
    else

        # Local machine.
        PS1="${BYEL}\W${END}\$(git_branch) ${BCYN}${BASS_CLEF}${END} "
    fi
fi

PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
