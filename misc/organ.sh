# #!/bin/bash

export DISPLAY=:0

window_ids=$(
    /opt/X11/bin/xlsclients -l |
        grep -E '^(Window |  Name)' |
        paste - - |
        grep -E 'Name: +GrandOrgue' |
        awk '{print $2}' |
        tr -d :
)

if [[ -z "$window_ids" ]]; then
    ssh organ &

    while ! /opt/X11/bin/xlsclients -l 2>/dev/null |
        grep -q 'Name:  GrandOrgue'; do
        sleep 0.25
    done

    # GrandOrgue creates XQuartz windows in several waves during startup.
    for _ in {1..12}; do
        /opt/homebrew/bin/xdotool \
            search --onlyvisible --class 'GrandOrgue' 2>/dev/null |
            while read -r id; do
                /opt/homebrew/bin/xdotool windowminimize "$id" 2>/dev/null
            done

        sleep 0.5
    done
else
    for window_id in $window_ids; do
        /opt/X11/bin/xkill -id "$window_id"
    done
fi
