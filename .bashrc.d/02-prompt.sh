#!/bin/bash

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')

# Print color-coded, abbreviated Git status and branch.
git_info() {

    # Bail if this isn't a git repo.
    if git status 2>&1 | grep '^fatal: not a git repo' &> /dev/null; then
        false
        return
    else
        # echo -ne " ${RYEL}[${REND}"
        echo -n ' '
    fi

    # Force Git to preserve colorized output throughout the pipeline.
    git -c color.ui=always status -sb |
    awk -v "ellipsis=$ELLIPSIS" '{

        # readline accepts \x01 and \x02 as non-printable text delimiters for
        # ANSI escape sequences (e.g., color codes).
        # - https://superuser.com/a/301355
        # - https://stackoverflow.com/a/43462720
        # - https://git.savannah.gnu.org/cgit/readline.git/tree/display.c#n320
        # - https://en.wikipedia.org/wiki/ANSI_escape_code
        # 01: SOH (start of heading; i.e., start non-visible characters)
        # 02: STX (start of text;    i.e., end   non-visible characters)
        # 1B: ESC (escape)
        red = "\x01\x1B[0;31m\x02";
        grn = "\x01\x1B[0;32m\x02";
        yel = "\x01\x1B[0;33m\x02";
        end = "\x01\x1B[m\x02";

        # Translate Bash-specific \[ and \] to \001 and \002.
        gsub(/.\[31m/, red);
        gsub(/.\[32m/, grn);
        gsub(/.\[m/,   end);
        gsub(/\r/,     "");

        # Match branch line.
        if ($1 == "##") {

            # Trim out unnecessary text.
            sub(/No commits yet on /, "");

            # Break out local and remote branch names (if the latter exists).
            # If local is missing commits from remote, indicate whether a
            # fast-forward is possible. mawk unfortunately does not support
            # curly braces as defined in POSIX RE. Assuming that the branch
            # name does not contain a colon.
            # - https://stackoverflow.com/a/3651867
            if (sub(/\.\.\./, ":", $2)) {

                # Extract branch names while stripping out color codes.
                split($2, branches, ":");
                sub(/:[^ ]*/, "", $2);
                local  = substr(branches[1], 10, length(branches[1]) - 14);
                remote = substr(branches[2], 10, length(branches[2]) - 14);

                # Print local branch name in red if missing commits from
                # remote. If fast-forward possible, print indicator in green.
                # - https://stackoverflow.com/a/49272912
                if (index($0, "behind")) {
                    sub(/32/, "31");  # Change from green to red.
                    if (system("git merge-base --is-ancestor " local " " remote) == 0) {
                        $0 = $0 grn ">>" end;
                    }
                }
            }
            else {
                sub(/:/, "", $2);
                local = $2;
            }

            # Abbreviate branch name.
            max_branch_len = 6;
            ctrl_char_len = length(grn) + length(end);
            if ((length(local) - ctrl_char_len) > max_branch_len)
                local = substr(local, 0, length(grn) + max_branch_len) ellipsis;
            local = local end;

            # Shorten commit status.
            gsub(/ \[|\]/, "");
            sub(/ahead /, grn"+");
            sub(/(, )?behind /, red"-");
            sub(/^## /, "");

            print;
        }
        else {
            print $1;
        }
    }' |
    (read -r
     printf '%s\n' "$REPLY"
     sort -r | uniq -c | awk -v "end=$REND" '{printf substr($2, 0, length($2) - 4) $1 end}') |
    tr '\n' ' ' |
    sed 's/- /-/g; s/[- ]*$//'
    # echo -ne "${RYEL}]${REND}"
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
