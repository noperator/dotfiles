#!/bin/bash

BASS_CLEF=$(printf '\xf0\x9d\x84\xa2')
ELLIPSIS=$(printf '\xe2\x80\xa6')

# Print color-coded, abbreviated Git status and branch.
git_info() {

    # Bail if this isn't a git repo.
    if git status |& grep -i '^fatal: not a git repo' &>/dev/null; then
        false
        return
    else
        echo -ne "${CLR[BBL]}#${CLR[RED]}"
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
    #
    # Note: On macOS, install `gawk` for this to work.
    git -c color.ui=always status -sb . |
        perl -pe 's/([^\x01]?)(\x1B\[.*?m)([^\x02]?)/\1\x01\2\x02\3/g' |
        awk -v "ellipsis=$ELLIPSIS" -v "red=${CLR[RED]}" -v "grn=${CLR[GRN]}" -v "end=${CLR[END]}" '

    # Remove ANSI escape sequences.
    function strip_ansi(str) {
        gsub(/\x01\x1B\[[;0-9]*m\x02/, "", str);
        return str;
    }

    {
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
                branch_str = strip_ansi($2);
                split(branch_str, branch_arr, ":");
                sub(/:[^ ]*/, "", $2);  # Remove remote branch.
                local_branch = branch_arr[1];
                remote_branch = branch_arr[2];

                # Print local branch name in red if missing commits from
                # remote. If fast-forward possible, print indicator in green.
                # - https://stackoverflow.com/a/49272912
                if (index($0, "behind")) {
                    branch_color = red;
                    check_fastfwd = "git merge-base --is-ancestor '\''" local_branch "'\'' '\''" remote_branch "'\''";
                    if (system(check_fastfwd) == 0) {
                        fastfwd = grn ">>";
                    }
                }
            }
            else {
                sub(/:/, "", $2);
                local_branch = strip_ansi($2);
            }

            # Abbreviate branch name.
            max_branch_len = 6;
            if ((length(local_branch)) > max_branch_len)
                local_branch = substr(local_branch, 0, max_branch_len) ellipsis;

            # Shorten commit status (remainder of line after $2).
            $1 = $2 = "";  # Only commit status will remain in $0.
            gsub(/^ *\[|\] *$/, "");
            sub(/ahead /, grn "+");
            sub(/(, )?behind /, red "-");
            commit_stat = $1;

            print branch_color local_branch end ":" commit_stat fastfwd end;
        }
        else {
            print $1;
        }
    }' |
        (
            read -r
            printf '%s\n' "$REPLY"
            sort -r | uniq -c | awk -v "yel=${CLR[YEL]}" -v "end=${CLR[END]}" '{printf $2 yel $1 end}'
        ) |
        tr '\n' ':' |
        perl -pe "s/:$(sed <<<${CLR[END]} 's/\[/\\[/'):/:/g; s/:*$//" |
        sed -E "s/:/${CLR[BBL]}:${CLR[END]}/g"
}

# Print abbreviated working directory.
pwd_abbr() { sed <<<"$PWD" -E "s|$HOME|~|; s|(\.?[^/])[^/]*/|\1/|g"; }

shpool_count() {
    local count=$(shpool list 2>/dev/null | tail -n +2 | wc -l)
    if [[ "$count" -gt 0 ]]; then
        echo -ne "${CLR[BBL]}:${CLR[END]}${CLR[BLU]}$count${CLR[END]}"
    fi
}

ssh_agent_pubkey_count() {
    local count=$(ssh-add -l 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
        echo -ne "${CLR[BBL]}:${CLR[END]}${CLR[BLU]}$count${CLR[END]}"
    fi
}

PWD_ABBR="${PS_CLR[YEL]}\$(pwd_abbr)${PS_CLR[END]}"
GIT_INFO="\$(git_info)"
SHPOOL_INFO="\$([ -n \"\$SHPOOL_SESSION_NAME\" ] && echo \"${PS_CLR[BBL]}?${PS_CLR[BLU]}\$SHPOOL_SESSION_NAME${PS_CLR[END]}\")"
PS1="$PWD_ABBR$SHPOOL_INFO$GIT_INFO"
AUTHORITY="${PS_CLR[CYN]}\u\$(ssh_agent_pubkey_count)${PS_CLR[BBL]}@${PS_CLR[MAG]}\h\$(shpool_count)${PS_CLR[BBL]}/"
PS1_CLR="${PS_CLR[CYN]}"
PS2_CLR="${PS_CLR[CYN]}"
PS1_SYM='$'
PS2_SYM='>'

# Check terminal type and location. We can get more creative with Unicode
# characters on a pseudo terminal device. Native terminal device likely implies
# no Unicode support.
if ! tty | grep -E 'tty[^s]' &>/dev/null; then
    PS1_SYM="$BASS_CLEF"
    PS2_SYM="$ELLIPSIS"

    # Remote server; prepend authority string.
    if [[ "$REMOTE_SHELL" == 'true' ]]; then
        PS1="$AUTHORITY$PS1"
        PS1_CLR="${PS_CLR[RED]}"
    fi

    if [[ -n "$SHPOOL_SESSION_NAME" ]]; then
        PS1_CLR="${PS_CLR[YEL]}"
    fi
fi

# Show last command's wall time, and print it colorized according to the last
# command's exit code.
# - https://stackoverflow.com/a/1862762
# - https://unix.stackexchange.com/a/227150
timer_start() {
    TIMER=${TIMER:-$SECONDS}
}
timer_stop() {
    TIMER_SHOW=$(($SECONDS - $TIMER))
    TIMER_MIN=$(($TIMER_SHOW / 60))
    TIMER_SEC=$(($TIMER_SHOW % 60))
    TIMER_PROMPT=''
    if [[ "$TIMER_MIN" > 0 ]]; then
        TIMER_PROMPT="${TIMER_PROMPT}${TIMER_MIN}m"
    fi
    if [[ "$TIMER_SEC" > 0 ]]; then
        TIMER_PROMPT="${TIMER_PROMPT}${TIMER_SEC}s"
    fi
    if [[ -n "$TIMER_PROMPT" ]]; then
        TIMER_PROMPT=" ${TIMER_PROMPT}"
    fi
    unset TIMER
}
trap 'timer_start' DEBUG
exit_code_color() {
    if [[ "$LAST_HISTCMD" == "$LAST_LAST_HISTCMD" ]]; then
        echo -e "${CLR[GRN]}"
    elif [[ "$LAST_EXIT_CODE" == 0 ]]; then
        echo -e "${CLR[GRN]}"
    else
        echo -e "${CLR[RED]}"
    fi
}
PS1="$PS1\$(exit_code_color)\${TIMER_PROMPT}${PS_CLR[END]}"

# Override Python virtual environment prompt indicator.
# - https://stackoverflow.com/a/20026992
export VIRTUAL_ENV_DISABLE_PROMPT=1
venv_info() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo -ne "${CLR[BMA]}(${CLR[END]}"
        echo -ne "${CLR[BCY]}${VIRTUAL_ENV##*/}${CLR[END]}"

        echo -ne "${CLR[BMA]})${CLR[END]}"
        echo -n ' '
    fi
}
export PS1="\$(venv_info)$PS1"

# Finalize prompt variables.
PS1="$PS1\n$PS1_CLR$PS1_SYM${PS_CLR[END]} "
PS2="$PS2_CLR$PS2_SYM${PS_CLR[END]} "

set_title() {
    if [[ "$REMOTE_SHELL" == 'true' ]]; then
        echo -ne "\e]2;${USER}@${HOSTNAME}:${PWD}\007"
    else
        echo -ne "\e]2;${PWD}\007"
    fi
}

prompt_command() {
    # Set Alacritty title to current working directory, which is picked up when
    # `window.dynamic_title: true` in Alacritty config. This isn't really
    # prompt-related, but this is the best place to put it so the terminal
    # title is always kept up to date.
    # - https://github.com/alacritty/alacritty/issues/3588#issuecomment-613189338
    set_title

    LAST_EXIT_CODE="$?"
    LAST_LAST_HISTCMD="$LAST_HISTCMD"
    LAST_HISTCMD=$(fc -l -1 | awk '{print $1}')
    timer_stop
    history -a
}
PROMPT_COMMAND='prompt_command'
