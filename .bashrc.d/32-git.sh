#!/bin/bash

alias ga='git add'
alias gd='git diff'
alias gds='git diff --staged'
alias gs='git status'
alias gss='git status -s'
alias gcl="git config --list --show-origin | column -t -s \"$(printf '\t')\""
gl() {
    if [[ -z "$@" ]]; then
        FOLLOW=''
    else
        FOLLOW='--follow'
    fi
    nowrap git --no-pager log --max-count=20 --color=always --date=short --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an <%ae>%Cgreen%d %Creset%s' $FOLLOW "$@"
    echo
}
alias glg='git log --graph --simplify-by-decoration --oneline --all'
gc () {
    MESSAGE="$@"
    LENGTH=$(echo -n "$MESSAGE" | wc -c | tr -d ' ')
    if [[ "$LENGTH" -gt 50 ]]; then
        echo "Subject is too long ($LENGTH characters). Let's get it down to 50."
    else
        git commit --message "$MESSAGE" && \
        gl
    fi
}
alias gcv='git commit -v'
alias gb='git branch -a'
alias gfo='git fetch origin && git status'
alias gau='git update-index --assume-unchanged'
alias gnau='git update-index --no-assume-unchanged'
