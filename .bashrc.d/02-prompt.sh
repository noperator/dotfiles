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
    awk -v "ellipsis=$ELLIPSIS" -v "red=${CLR[RED]}" -v "grn=${CLR[GRN]}" -v "end=${CLR[END]}" '{

        branch_color = grn;

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

                # Extract plain text branch names.
                branch_str = $2;
                gsub(/\x01\x1B\[[;0-9]*m\x02/, "", branch_str);  # Remove ANSI escape sequences.
                split(branch_str, branch_arr, ":");
                sub(/:[^ ]*/, "", $2);  # Remove remote branch.
                local_branch = branch_arr[1];
                remote_branch = branch_arr[2];

                # Print local branch name in red if missing commits from
                # remote. If fast-forward possible, print indicator in green.
                # - https://stackoverflow.com/a/49272912
                if (index($0, "behind")) {
                    branch_color = red;
                    check_ff_cmd = "git merge-base --is-ancestor '\''" local_branch "'\'' '\''" remote_branch "'\''";
                    if (system(check_ff_cmd) == 0) {
                        ff_sym = grn ">>";
                    }
                }
            }
            else {
                sub(/:/, "", $2);
                gsub(/\x01\x1B\[[;0-9]*m\x02/, "", $2);  # Remove ANSI escape sequences.
                local_branch = $2;
            }

            # Abbreviate branch name.
            max_branch_len = 6;
            if ((length(local_branch)) > max_branch_len)
                local_branch = substr(local_branch, 0, max_branch_len) ellipsis;

            # Shorten commit status (remainder of line after $2).
            $1 = $2 = "";
            gsub(/^ *\[|\] *$/, "");
            sub(/ahead /, grn "+");
            sub(/(, )?behind /, red "-");

            print branch_color local_branch ff_sym $3 end;
        }
        else {
            print $1;
        }
    }' |
    (read -r
     printf '%s\n' "$REPLY"
     sort -r | uniq -c | awk -v "yel=${CLR[YEL]}" -v "end=${CLR[END]}" '{printf $2 yel $1 end}') |
    tr '\n' ' ' |
    sed -E 's/ +/ /g; s/ *$//'
}

# Print abbreviated working directory.
pwd_abbr() { <<< "$PWD" sed -E "s|$HOME|~|; s|(\.?[^/])[^/]*/|\1/|g"; }

PWD_ABBR="${PS_CLR[YEL]}\$(pwd_abbr)${PS_CLR[END]}"
GIT_INFO="\$(git_info)"
PS1="$PWD_ABBR$GIT_INFO"
AUTHORITY="${PS_CLR[CYN]}\u${PS_CLR[END]}@${PS_CLR[MAG]}\h${PS_CLR[END]}:"
PS1_CLR="${PS_CLR[CYN]}"
PS2_CLR="${PS_CLR[CYN]}"

# Check terminal type and location. We can get more creative with Unicode
# characters on a pseudo terminal device. Native terminal device likely implies
# no Unicode support.
if ! tty | grep -E 'tty[^s]' &> /dev/null; then
    PS1_SYM="$BASS_CLEF"
    PS2_SYM="$ELLIPSIS"

    # Remote server. Prepend authority string.
    if [[ -v SSH_TTY ]]; then
        PS1="$AUTHORITY$PS1"
        PS1_CLR="${PS_CLR[RED]}"
    fi
fi

PS1="$PS1 $PS1_CLR$PS1_SYM${PS_CLR[END]} "
PS2="$PS2_CLR$PS2_SYM${PS_CLR[END]} "

PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
