#!/bin/bash

if [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    alias docker="sudo $(which docker 2> /dev/null)"
fi

alias dil='docker image ls'
dcl() {
    docker container ls -a
}
alias ddf='docker system df'
dh() { docker history --format '{{.ID}}@{{.CreatedSince}}@{{.Size}}@{{.Comment}}' "$1" | head | column -t -s '@'; }
