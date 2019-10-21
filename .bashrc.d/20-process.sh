#!/bin/bash

case "$OSTYPE" in
    'linux-gnu')
        alias ps="$(which ps) --ppid 2 -p 2 -N -C ps -N -o user,pid,ppid,vsize:8,time,stime,cmd"
        alias ph="ps -H"
        alias pt="ps --sort=start_time"
        alias pm="ps --sort=vsize"
        ;;
    'darwin'*)
        alias ph='pstree'
        ;;
esac

alias pg='pgrep -afli'
alias pkill="$(which pkill) -afi"
