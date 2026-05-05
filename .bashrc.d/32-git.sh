#!/bin/bash

# Determine the default branch using a fallback chain.
_git_default_branch() {
    local branch
    branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
    [[ -n "$branch" ]] && echo "$branch" && return 0

    for b in main master; do
        if git show-ref --verify --quiet "refs/heads/$b"; then
            echo "$b" && return 0
        fi
    done

    return 1
}

# Print a brief, color-coded Git log truncated at the terminal window width.
# Can alternatively use `tput rmam` and `tput smam` to disable and re-enable
# line wrapping, respectively.
gl() {
    if [[ -z "$@" ]]; then
        FOLLOW=''
    else
        FOLLOW='--follow'
    fi

    local base_branch current_branch
    base_branch=$(_git_default_branch 2>/dev/null)
    current_branch=$(git branch --show-current 2>/dev/null)

    # Build set of commits unique to this branch (not reachable from base)
    declare -A _unique_hashes
    if [[ -n "$base_branch" && "$current_branch" != "$base_branch" ]]; then
        while IFS= read -r h; do
            _unique_hashes["$h"]=1
        done < <(git log "${base_branch}..HEAD" --format='%h' 2>/dev/null)
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
        while IFS= read -r LINE; do
            # Dim commits that already exist in the base branch
            if [[ -n "$base_branch" && "$current_branch" != "$base_branch" ]]; then
                local raw hash
                raw=$(sed 's/\x1b\[[0-9;]*m//g' <<<"$LINE")
                hash=$(awk '{print $1}' <<<"$raw")
                if [[ -n "$hash" && -z "${_unique_hashes[$hash]}" ]]; then
                    # LINE=$(sed 's/\x1b\[m/\x1b[2m/g; s/\x1b\[0m/\x1b[2m/g' <<<"$LINE")
                    LINE=$(sed 's/\x1b\[m/\x1b[0;2m/g; s/\x1b\[0m/\x1b[0;2m/g' <<<"$LINE")
                    LINE=$'\e[2m'"${LINE}"
                fi
            fi
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
    local base_branch
    base_branch=$(_git_default_branch 2>/dev/null) || base_branch="main"

    local merged
    merged=$(git branch --merged "$base_branch" 2>/dev/null | sed 's/^[* ]*//')

    git branch --format=$'%(committerdate:iso)\t%(committerdate:short)\t%(HEAD)\t%(refname:short)\t%(subject)' |
        sort -rt$'\t' -k1 |
        cut -f2- |
        awk -v merged="$merged" -v base="$base_branch" -F'\t' '
            BEGIN { split(merged, a, "\n"); for (i in a) m[a[i]] = 1 }
            {
                date=$1; head=$2; name=$3; subj=$4
                is_current = (head == "*")
                is_merged  = (name in m) && !is_current
                is_base    = (name == base)

                ahead = ""; behind = ""
                if (!is_merged && !is_base) {
                    cmd = "git rev-list --left-right --count " base "..." name " 2>/dev/null"
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

# pf() {
#     git ls-files |
#         parallel file | grep text | sed -E 's/:.*//' |
#         while read file; do
#             print-file "$file"
#         done |
#         cat -s
# }

# Usage:
#   git_clone_pin <url-or-repo> [ref]
git_clone_pin() {
    if (($# < 1 || $# > 2)); then
        echo "Usage: git_clone_pin <url-or-repo> [ref]" >&2
        return 1
    fi

    local input="$1" explicit_ref="${2:-}"
    input="${input%%\?*}"
    input="${input%%\#*}"
    input="${input%/}"

    local repo_url="" repo_name="" ref_from_url="" ref=""
    local dest_suffix dest

    # ---- parse GitHub URLs
    if [[ "$input" =~ ^https?://github\.com/([^/]+)/([^/]+)(/.*)?$ ]]; then
        local owner="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]%.git}"
        local rest="${BASH_REMATCH[3]:-}"

        repo_url="https://github.com/$owner/$repo.git"
        repo_name="$repo"

        # Extract ref from /releases/tag/<ref> OR /tree/<ref> OR /commit/<sha>
        if [[ "$rest" =~ ^/releases/tag/(.+)$ || "$rest" =~ ^/tree/(.+)$ || "$rest" =~ ^/commit/([0-9a-fA-F]{7,40})$ ]]; then
            ref_from_url="${BASH_REMATCH[1]}"
        fi
    else
        # Assume it's already a git remote URL
        repo_url="$input"
        repo_name="$(basename -s .git "$repo_url")"
    fi

    ref="${explicit_ref:-$ref_from_url}"
    dest_suffix="${ref:-default}"
    dest_suffix="${dest_suffix//\//-}"
    dest_suffix="${dest_suffix// /_}"
    dest="${repo_name}-${dest_suffix}"

    # ---- common git opts (no blob filtering)
    local -a G=(git -c protocol.version=2)
    local -a CLONE_SHALLOW=(clone --depth 1 --single-branch --no-tags)
    local -a FETCH_SHALLOW=(fetch --depth 1 --no-tags)
    local -a ENV=(env GIT_TERMINAL_PROMPT=0)

    _clone_default() { "${ENV[@]}" "${G[@]}" "${CLONE_SHALLOW[@]}" "$repo_url" "$1"; }
    _clone_ref() { "${ENV[@]}" "${G[@]}" "${CLONE_SHALLOW[@]}" --branch "$1" "$repo_url" "$2"; }

    _fetch_checkout() { # $1=commit-ish $2=dest
        mkdir -p "$2" && cd "$2" || return 1
        "${G[@]}" init -q || return 1
        "${G[@]}" remote add origin "$repo_url" || return 1
        "${ENV[@]}" "${G[@]}" "${FETCH_SHALLOW[@]}" origin "$1" || return 1
        "${G[@]}" checkout -q FETCH_HEAD
    }

    # ---- no ref: shallow default branch
    if [[ -z "$ref" ]]; then
        echo "Shallow cloning default branch -> $dest"
        _clone_default "$dest"
        return $?
    fi

    # ---- if it looks like a SHA, try commit first
    if [[ "$ref" =~ ^[0-9a-fA-F]{7,40}$ ]]; then
        echo "Fetching commit -> $dest"
        _fetch_checkout "$ref" "$dest" && return 0
        cd - >/dev/null 2>&1 || true
        rm -rf "$dest"
    fi

    # ---- try tag
    if "${G[@]}" ls-remote --tags "$repo_url" "refs/tags/$ref" | grep -q .; then
        echo "Cloning tag '$ref' -> $dest"
        _clone_ref "$ref" "$dest" && return 0
    fi

    # ---- try branch
    if "${G[@]}" ls-remote --heads "$repo_url" "refs/heads/$ref" | grep -q .; then
        echo "Cloning branch '$ref' -> $dest"
        _clone_ref "$ref" "$dest" && return 0
    fi

    # ---- last try: commit-ish
    echo "Trying '$ref' as commit-ish -> $dest"
    _fetch_checkout "$ref" "$dest" && return 0

    # ---- fallback
    echo "Pin '$ref' not found. Falling back to default branch -> ${repo_name}-default"
    cd - >/dev/null 2>&1 || true
    rm -rf "$dest"
    _clone_default "${repo_name}-default"
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
