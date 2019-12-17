#!/bin/bash

alias ga='git add'
gc () {
    MESSAGE="$@"
    LENGTH=$(echo -n "$MESSAGE" | wc -c | tr -d ' ')
    if [[ "$LENGTH" -gt 50 ]]; then
        echo "Subject is too long ($LENGTH characters). Let's get it down to 50."
    else
        git commit --message "$MESSAGE"
    fi
}
alias gd='git diff'
alias gs='git status'
alias gcl="git config --list --show-origin | column -t -s \"$(printf '\t')\""
alias gl="git log --date=short --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s'"
alias gb='git branch -a'
