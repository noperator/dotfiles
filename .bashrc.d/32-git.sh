#!/bin/bash

# Print a brief, color-coded Git log truncated at the terminal window width.
# Can alternatively use `tput rmam` and `tput smam` to disable and re-enable
# line wrapping, respectively.
gl() {
    if [[ -z "$@" ]]; then
        FOLLOW=''
    else
        FOLLOW='--follow'
    fi

    export COLUMNS
    (
        git --no-pager log \
            --max-count=20 \
            --color=always \
            --date=short \
            --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an <%ae>%Cgreen%d %Creset%s' $FOLLOW "$@"
        echo
    ) |
        while read LINE; do
            # Cut while ignoring ANSI-type escape sequences. Regex source:
            # - https://unix.stackexchange.com/a/46982
            perl <<<"$LINE" -pe 's/^((?:(?>(?:\e\[.*?m)*).){$ENV{COLUMNS}}).*/$1\e[m/'
        done
}

# Post a commit while validating the message length.
gc() {
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
# alias gb='git branch -a'
gb() {
    local merged
    merged=$(git branch --merged main 2>/dev/null | sed 's/^[* ]*//')

    git branch --format=$'%(committerdate:iso)\t%(committerdate:short)\t%(HEAD)\t%(refname:short)\t%(subject)' |
        sort -rt$'\t' -k1 |
        cut -f2- |
        awk -v merged="$merged" -F'\t' '
            BEGIN { split(merged, a, "\n"); for (i in a) m[a[i]] = 1 }
            {
                date=$1; head=$2; name=$3; subj=$4
                is_current = (head == "*")
                is_merged  = (name in m) && !is_current
                is_main    = (name == "main")

                ahead = ""; behind = ""
                if (!is_merged && !is_main) {
                    cmd = "git rev-list --left-right --count main..." name " 2>/dev/null"
                    if ((cmd | getline result) > 0) {
                        split(result, ab, "\t")
                        behind = "-" ab[1]; ahead = "+" ab[2]
                    }
                    close(cmd)
                }

                display_name = name
                if (is_current) display_name = "\033[32m" name "\033[0m"
                line = date "\t" head " " display_name "\t" ahead "\t" behind "\t" subj
                print is_merged ? "\033[2m" line "\033[0m" : line
            }
        ' |
        column -ts$'\t'
}

alias gcl="git config --list --show-origin | column -t -s \"$(printf '\t')\""
alias gcv='git commit -v'
alias gd='git diff'
alias gds='git diff --staged'
alias gfo='git fetch origin && git status'
alias glg='git log --graph --simplify-by-decoration --oneline --all'
gmo() {
    echo "origin/$(git branch --show-current)"
    git merge "origin/$(git branch --show-current)"
}
alias gnau='git update-index --no-assume-unchanged'
alias gs='git status'
alias gss='git status -s'

trt() {
    wget 'https://gist.githubusercontent.com/noperator/4eba8fae61a23dc6cb1fa8fbb9122d45/raw/eab7566e53b33240ff6bf7c3241c86a4048ed374/README.md'
}

_stat_size() {
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f '%z' "$1"
    else
        stat -c '%s' "$1"
    fi
}

gf() {
    local OPTIND=1
    local sep=$'\x1f'
    local n_flag=0

    while getopts "n" opt; do
        case $opt in
        n) n_flag=1 ;;
        esac
    done

    if [[ "$n_flag" -eq 1 ]]; then
        git ls-files | while read -r file; do
            grep -qI '' "$file" 2>/dev/null && echo "$file"
        done | sort
    else
        git ls-files | while read -r file; do
            grep -qI '' "$file" 2>/dev/null && echo "$(_stat_size "$file")${sep}${file}"
        done | sort -n | column -ts "$sep"
    fi
}

pf() {
    if [ -t 0 ]; then
        gf -n | while read -r file; do
            print-file "$file"
        done
    else
        while read -r file; do
            print-file "$file"
        done
    fi
}

gw() {
    local branch="$1"
    local root=$(git rev-parse --show-toplevel 2>/dev/null || (cd "$(git rev-parse --git-common-dir)/.." && pwd))
    root=$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)

    if [[ -z "$branch" ]]; then
        gb
        return
    fi

    # Check if branch is already checked out in any worktree
    local existing=$(git worktree list --porcelain | awk -v b="$branch" '
        /^worktree / { wt=$2 }
        /^branch refs\/heads\// { br=substr($2,12); if (br==b) print wt }
    ')
    if [[ -n "$existing" ]]; then
        cd "$existing"
        return
    fi

    local path="$root/.worktrees/$branch"
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        git worktree add "$path" "$branch"
    else
        git worktree add -b "$branch" "$path"
    fi && cd "$path"
}

_gw_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local branches=$(git branch --format='%(refname:short)' 2>/dev/null)
    COMPREPLY=($(compgen -W "$branches" -- "$cur"))
}
complete -F _gw_complete gw

alias gr='cd $(git rev-parse --show-toplevel)'
alias grr='cd $(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)'
