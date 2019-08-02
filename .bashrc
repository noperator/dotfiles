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
gir() { g -r "$@" .; }

# Config
alias vv="vim $HOME/.vimrc"
alias vb="vim $HOME/.bashrc"
alias sb="source $HOME/.bash_profile"
alias vbh="vim $HOME/.bash_history"
alias tbh="tail $HOME/.bash_history"
gbh() { g "$@" "$HOME/.bash_history"; }
gbr() { g "$@" "$HOME/.bashrc"; }

# Directory shortcuts
alias cds="cd $HOME/.ssh"

# find
ff()  { find "$@" ! -empty -type f -printf '%.19T+@%s@%p\n' 2>/dev/null | while read LINE; do printf '%q\n' "$LINE"; done | column -t -s '@' | cut -c -"$COLUMNS"; }
ft() { ff "$@" | sort -n; }
fs() { ff "$@" | sort -n -k 2; }

# ls
alias ls='ls -G'
alias lt='ls -FlAtr'
alias lh='ls -laSrh'

# LastPass
alias lps='lpass show -Gx'
alias lpe='lpass edit'
alias lpt='lpass status'
alias lpa='lpass add'

# Misc
export VISUAL='vim'
export EDITOR="$VISUAL"
alias no='>/dev/null 2>&1'
alias errcho='>&2 echo'
alias l='clear'
alias cdt='cd /tmp'
alias cdl="cd $HOME/Downloads"
alias ltd="lt $HOME/Downloads"
alias pg='pgrep -afli'
alias pkill='/usr/bin/pkill -afi'
alias less='less -i'
alias mount="$(which mount) | sed -E 's/ on |\(|\)/@/g' | column -t -s @ | cut -c -\$COLUMNS"
alias png='ping google.com'
arping() { "$(which arping)" -c 1 "$@" | g 'bytes from' || echo "No reply from $@."; }
geo() { curl -s "https://ipapi.co/$@/json/"; }
sudo() { errcho "${red}[sudo] $@${end}"; "$(which sudo)" "$@"; }
tree() { "$(which tree)" -tD "$@" | ccat; }
wl() { which "$@" && ls -l $(which "$@"); }
