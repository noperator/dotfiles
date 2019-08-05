# Colors
blk=$'\e[0;30m' ; BLK='\[\e[0;30m\]' ; BBLK='\[\e[1;30m\]'
red=$'\e[0;31m' ; RED='\[\e[0;31m\]' ; BRED='\[\e[1;31m\]'
grn=$'\e[0;32m' ; GRN='\[\e[0;32m\]' ; BGRN='\[\e[1;32m\]'
yel=$'\e[0;33m' ; YEL='\[\e[0;33m\]' ; BYEL='\[\e[1;33m\]'
blu=$'\e[0;34m' ; BLU='\[\e[0;34m\]' ; BBLU='\[\e[1;34m\]'
prp=$'\e[0;35m' ; PRP='\[\e[0;35m\]' ; BPRP='\[\e[1;35m\]'
cyn=$'\e[0;36m' ; CYN='\[\e[0;36m\]' ; BCYN='\[\e[1;36m\]'
gry=$'\e[0;37m' ; GRY='\[\e[0;37m\]' ; BGRY='\[\e[1;37m\]'
end=$'\e[0m'    ; END='\[\e[m\]'

# Prompt
PS1="${BYEL}\W${END} ${BCYN}$(printf '\xf0\x9d\x84\xa2')${END} "
PS2="${BCYN}$(printf '\xe2\x80\xa6')${END} "
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Grep
alias g='grep -iE --color'
alias vg='g -v'
gr() { g -r "$@" .; }

# Config
alias vv="vim $HOME/.vimrc"
alias vb="vim $HOME/.bashrc"
alias sb="source $HOME/.bash_profile"
alias vbh="vim $HOME/.bash_history"
alias tbh="tail $HOME/.bash_history"
gbh() { g "$@" "$HOME/.bash_history"; }
gbr() { g "$@" "$HOME/.bashrc"; }

# Directory shortcuts
alias cdt='cd /tmp'
alias cds="cd $HOME/.ssh"
alias cdl="cd $HOME/Downloads"
alias ltd="lt $HOME/Downloads"

# find
ff() { find "$@" ! -empty -type f -printf '%.19T+@%s@%p\n' 2>/dev/null | while read LINE; do printf '%q\n' "$LINE"; done | column -t -s '@' | cut -c -"$COLUMNS"; }
ft() { ff "$@" | sort -n; }
fs() { ff "$@" | sort -n -k 2; }

# ls
alias ls='ls -G'
alias lt='ls -FlAtr'
alias lh='ls -SlAhr'

# LastPass
alias lps='lpass show -Gx'
alias lpe='lpass edit'
alias lpt='lpass status'
alias lpa='lpass add'

# Git
alias gc='git commit -m'
alias gd='git diff'
alias gs='git status'
gcl() { git clone "$@" && cd $(echo "$@" | sed -E 's|.*/([^/]*)\.git|\1|'); }

# Misc
export VISUAL='vim'
export EDITOR="$VISUAL"
alias no='>/dev/null 2>&1'
alias errcho='>&2 echo'
alias l='clear'
alias pg='pgrep -afli'
alias pkill="$(which pkill) -afi"
alias less='less -i'
alias mount="$(which mount) | sed -E 's/ on |\(|\)/@/g' | column -t -s @ | cut -c -\$COLUMNS"
alias png='ping google.com'
arping() { "$(which arping)" -c 1 "$@" | g 'bytes from' || echo "No reply from $@."; }
geo() { curl -s "https://ipapi.co/$@/json/"; }
sudo() { errcho "${red}[sudo] $@${end}"; "$(which sudo)" "$@"; }
tree() { "$(which tree)" -tD "$@" | ccat; }
wl() { which "$@" && ls -l $(which "$@"); }

TERA=1099511627776
GIGA=1073741824
MEGA=1048576
KILO=1024
dud() {
  du -s * | sort -rn | while read l; do
    SIZE=$( echo "`echo \"$l\" | awk '{print $1}'`*512" | bc )
    NAME=$( echo "$l" | sed -E 's/^[0-9]*[[:space:]]*//' |\
            sed -E 's/[[:space:]]*$//' )
    if   [[ $SIZE -ge $GIGA ]]; then DENOM=$GIGA && DENOM_S="${red}GB${end}"
    elif [[ $SIZE -ge $MEGA ]]; then DENOM=$MEGA && DENOM_S="${yel}MB${end}"
    elif [[ $SIZE -ge $KILO ]]; then DENOM=$KILO && DENOM_S="${grn}KB${end}"
    else                             DENOM=1     && DENOM_S="${gry}B${end}"; fi
    python2 -c "print str(round(${SIZE}.0/$DENOM,2)) + str(\"|$DENOM_S|$NAME\")"
  done | column -t -s '|'
}
