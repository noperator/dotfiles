#!/bin/bash

case "$OSTYPE" in
    'linux-gnu'*)
        alias ps="$(which ps) --ppid 2 -p 2 -N -C ps -N -o user,pid,ppid,vsize:8,time,stime,cmd"
        alias ph="ps -H"
        alias pt="ps --sort=start_time"
        alias pm="ps --sort=vsize"
        alias pkill="$(which pkill) -fi"
        alias pkill9="$(which pkill) -9 -fi"
        ;;
    'darwin'*)
        alias ph='pstree'
        alias pkill="$(which pkill) -afi"
        alias pkill9="$(which pkill) -9 -afi"
        ;;
esac

pg() { pgrep -afli "$@" | grep -iE --color=always "$@" | grep -vE '^[0-9]+\ grep'; }
