#!/bin/bash

alias lps='lpass show -Gx'
alias lpe='lpass edit'
alias lpt='lpass status'
alias lpa='lpass add'

pwg() { LC_ALL=C tr -dc 'A-Za-z0-9!"#$%&'\''()*+,-./:;<=>?@[\]^_`{|}~' </dev/urandom | head -c 32 ; echo; }
