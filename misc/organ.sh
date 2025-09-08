#!/bin/bash

window_ids=$(
    /opt/X11/bin/xlsclients -l |
        grep -E '^(Window |  Name)' |
        paste - - |
        grep -E 'Name: +GrandOrgue' |
        awk '{print $2}' |
        tr -d :
)

if [[ -z "$window_ids" ]]; then
    ssh organ
else
    for window_id in $window_ids; do
        /opt/X11/bin/xkill -id "$window_id"
    done
fi
