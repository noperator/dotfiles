#!/bin/bash

if [[ "$OSTYPE" == 'linux-gnu' ]]; then
    alias docker="sudo $(which docker)"
fi

alias dil='docker image ls'
alias dcl='docker container ls --format "{{.ID}}@{{.Image}}@{{.Command}}@{{.Status}}" | head | column -t -s "@"'
alias dcla='docker container ls -a --format "{{.ID}}@{{.Image}}@{{.Command}}@{{.Status}}" | head | column -t -s "@"'
alias ddf='docker system df'
dh() { docker history --format '{{.ID}}@{{.CreatedSince}}@{{.Size}}@{{.Comment}}' "$1" | head | column -t -s '@'; }
