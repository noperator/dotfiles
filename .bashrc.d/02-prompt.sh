#!/bin/bash

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')

# Using PS1-compatible colors according to a Stack Overflow post:
# - https://stackoverflow.com/a/43462720
PROMPT_GRN=$(echo -ne '\001\e[0;32m\002')
PROMPT_RED=$(echo -ne '\001\e[0;31m\002')
PROMPT_END=$(echo -ne '\001\e[m\002')

# Print color-coded, abbreviated Git status and branch.
git_info() {

    # Bail if this isn't a git repo.
    if git status 2>&1 | grep '^fatal: not a git repo' &> /dev/null; then
        false
        return
    else
        echo -n ' '
    fi

    # Use script utility to preserve colorized output throughout the pipeline,
    # as documented on this Stack Overflow post:
    # - https://stackoverflow.com/a/7646881
    git -c color.ui=always status -sb |
    awk -v "ellipsis=$ELLIPSIS" -v "grn=$PROMPT_GRN" -v "red=$PROMPT_RED" -v "end=$PROMPT_END" '{

        # Translate Bash-specific \[ and \] to \001 and \002.
        gsub(/.\[31m/, red);
        gsub(/.\[32m/, grn);
        gsub(/.\[m/,   end);
        gsub(/\r/,     "");
        if ($1 == "##") {

            # Trim out unnecessary text, remote tracking branch, etc.
            sub(/No commits yet on /, "");
            sub(/\.{3}.*/, "", $2);

            # Print branch name in red if missing commits.
            if (index($0, "behind"))
                sub(/32/, "31");

            # Abbreviate branch name.
            max_branch_len = 6;
            ctrl_char_len = length(grn) + length(end);
            if ((length($2) - ctrl_char_len) > max_branch_len)
                $2 = substr($2, 0, length(grn) + max_branch_len) ellipsis;
            $2 = $2 end;

            # Shorten commit status.
            gsub(/ \[|\]$/, "");
            sub(/ahead /, grn"+");
            sub(/(, )?behind /, red"-");

            print;
        }
        else {
            print $1"-";
        }
    }' |
    sort -ru |
    tr '\n' ' ' |
    sed 's/^## //; s/- /-/g; s/[- ]*$//'
}

# Print abbreviated working directory.
pwd_abbr() { <<< "$PWD" sed -E "s|$HOME|~|; s|(\.?[^/])[^/]*/|\1/|g"; }

# Set Bash prompt according to terminal type and location.
if tty | grep -E 'tty[^s]' &> /dev/null; then

    # Native terminal device, and likely no Unicode support.
    PS1="${BYEL}\$(pwd_abbr)${END}\$(git_info) ${BCYN}\$${END} "
    PS2="${BCYN}>${END} "
else

    # Pseudo terminal device.
    PS2="${BCYN}$ELLIPSIS${END} "
    if [[ -v SSH_TTY ]]; then

        # Remote server.
        PS1="${CYN}\u${END}${GRN}@${END}${PRP}\h${END}${GRN}:${END}${YEL}\$(pwd_abbr)${END}\$(git_info) ${RED}${BASS_CLEF}${END} "
    else

        # Local machine.
        PS1="${BYEL}\$(pwd_abbr)${END}\$(git_info) ${BCYN}${BASS_CLEF}${END} "
    fi
fi

PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
