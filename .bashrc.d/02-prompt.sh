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
        echo -n ' '
    fi

    # Force Git to preserve colorized output throughout the pipeline. For some
    # reason, Git doesn't surround its ANSI escape sequences with ASCII SOH/STX
    # bytes (which readline uses as non-printable text delimiters); manually
    # adding those delimiters with Perl so the terminal doesn't get screwed up.
    # 0x01: SOH (start of heading; i.e., start non-visible characters)
    # 0x02: STX (start of text;    i.e., end   non-visible characters)
    # 0x1B: ESC (escape)
    # - https://superuser.com/a/301355
    # - https://stackoverflow.com/a/43462720
    # - https://git.savannah.gnu.org/cgit/readline.git/tree/display.c#n320
    # - https://en.wikipedia.org/wiki/ANSI_escape_code
    git -c color.ui=always status -sb |
    perl -pe 's/([^\x01]?)(\x1B\[.*?m)([^\x02]?)/\1\x01\2\x02\3/g' |
    awk -v "ellipsis=$ELLIPSIS" '{

        red = "\x01\x1B[31m\x02";
        grn = "\x01\x1B[32m\x02";
        end = "\x01\x1B[m\x02";

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

                # Extract plain text branch names (i.e., without ANSI escape sequences).
                split($2, branches, ":");
                sub(/:[^ ]*/, "", $2);
                local  = substr(branches[1], length(grn) + 1, length(branches[1]) - (length(grn) + length(end)));
                remote = substr(branches[2], length(red) + 1, length(branches[2]) - (length(red) + length(end)));

                # Print local branch name in red if missing commits from
                # remote. If fast-forward possible, print indicator in green.
                # - https://stackoverflow.com/a/49272912
                if (index($0, "behind")) {
                    sub(/32/, "31");  # Change from green to red.
                    if (system("git merge-base --is-ancestor '\''" local "'\'' '\''" remote "'\''") == 0) {
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
     sort -r | uniq -c | awk -v "yel=$RYEL" -v "end=$REND" '{printf $2 yel $1 end}') |
    tr '\n' ' ' |
    sed 's/ $//'
}

# Print abbreviated working directory.
pwd_abbr() { <<< "$PWD" sed -E "s|$HOME|~|; s|(\.?[^/])[^/]*/|\1/|g"; }

PWD_ABBR="$YEL\$(pwd_abbr)$END"
GIT_INFO="\$(git_info)"
PS1="$PWD_ABBR$GIT_INFO"
AUTHORITY="$CYN\u$END@$MAG\h$END:"
PS1_CLR="$CYN"
PS1_SYM="$BASS_CLEF"
PS2_CLR="$CYN"
PS2_SYM="$ELLIPSIS"

# Set Bash prompt according to terminal type and location. Native terminal
# device (TTY) likely implies no Unicode support.
if tty | grep -E 'tty[^s]' &> /dev/null; then
    PS1_SYM='$'
    PS2_SYM='>'

# Pseudo terminal device.
else

    # Remote server. Prepend authority string.
    if [[ -v SSH_TTY ]]; then
        PS1="$AUTHORITY$PS1"
        PS1_CLR="$RED"
    fi
fi

PS1="$PS1 $PS1_CLR$PS1_SYM$END "
PS2="$PS2_CLR$PS2_SYM$END "

PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
