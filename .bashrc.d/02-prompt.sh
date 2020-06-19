#!/bin/bash

# Less efficient way to check if shell is local.
# if [[ $(awk -F = '/^ID/ {print $2}' /etc/os-release 2>/dev/null) == 'arch' ]] || \
#    [[ "$OSTYPE" == 'darwin'* ]]; then

# Print color-coded, abbreviated Git branch.
git_branch() {
    BRANCH=$(git branch 2> /dev/null |
    awk '{if ($1 == "*") {printf substr($2, 0, 6);
        if (length($2) > 6) print "…"}}')
    if [[ "$BRANCH" ]]; then
        echo -n " $BRANCH"
        # if [[ $(git status | grep -E '^Your branch is up to date with') ]]; then
        #     echo -e " ${grn}${BRANCH}${end}"
        # else
        #     echo -e " ${red}${BRANCH}${end}"
        # fi
    fi
}

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')

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
