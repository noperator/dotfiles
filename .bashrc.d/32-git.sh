#!/bin/bash

alias ga='git add'
alias gc='git commit --message'
alias gd='git diff'
alias gs='git status'
alias gcl="git config --list --show-origin | column -t -s \"$(printf '\t')\""
alias gl="git log --date=short --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s'"
alias gb='git branch -a'
