#!/bin/bash

# Print a brief, color-coded Git log truncated at the terminal window width.
# Can alternatively use `tput rmam` and `tput smam` to disable and re-enable
# line wrapping, respectively.
gl() {
    FOLLOW=''
    [[ -z "$@" ]] && FOLLOW='--follow'

    export COLUMNS
    git --no-pager log \
        --max-count=20 \
        --color=always \
        --date=short \
        --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an <%ae>%Cgreen%d %Creset%s' $FOLLOW "$@" |
    while read LINE; do
        # Cut while ignoring ANSI-type escape sequences. Regex source:
        # - https://unix.stackexchange.com/a/46982
        <<< "$LINE" perl -pe 's/^((?:(?>(?:\e\[.*?m)*).){$ENV{COLUMNS}}).*/$1\e[m/'
    done
}

# Post a commit while validating the message length.
gc () {
    MESSAGE="$@"
    LENGTH=$(echo -n "$MESSAGE" | wc -c | tr -d ' ')
    if [[ "$LENGTH" -gt 50 ]]; then
        echo "Subject is too long ($LENGTH characters). Let's get it down to 50."
    else
        git commit --message "$MESSAGE" &&
        gl
    fi
}

alias ga='git add'
alias gau='git update-index --assume-unchanged'
alias gb='git branch -a'
alias gcl="git config --list --show-origin | column -t -s \"$(printf '\t')\""
alias gcv='git commit -v'
alias gd='git diff'
alias gds='git diff --staged'
alias gfo='git fetch origin && git status'
alias glg='git log --graph --simplify-by-decoration --oneline --all'
alias gmo='git merge origin'
alias gnau='git update-index --no-assume-unchanged'
alias gs='git status'
alias gss='git status -s'
