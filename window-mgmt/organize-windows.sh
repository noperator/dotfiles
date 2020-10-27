#!/bin/bash

alias yabai=/usr/local/bin/yabai
get_displays() { yabai -m query --displays; }
get_windows()  { yabai -m query --windows;  }
get_display_index() { <<< "$DISPLAY" jq '.index';      }
get_space_index()   { <<< "$DISPLAY" jq ".spaces[$1]"; }
notify() { osascript -e 'display notification "'"$1"'" with title "'"Auto Window"'"'; }

# This function takes relative space/display arrangement indices, determines
# the absolute index for those values, and moves windows accordingly.
# For example:
# - "move_window Firefox 0 0"     = Move Firefox       to the first  space on the first  display
# - "move_window Slack   2 1"     = Move Slack         to the third  space on the second display
# - "move_window Firefox 1 1 144" = Move window ID 144 to the second space on the second display
# $1: Application name
# $2: Relative space index
# $3: Relative display index
# $4: Specific window IDs to move (optional)
move_window()
{
    APP="$1"
    REL_SPACE_INDEX="$2"
    REL_DISP_INDEX="$3"
    WINDOW_IDS="$4"

    # Get windows IDs associated with the application name, and bail if none
    # exist.
    if [[ -z "$WINDOW_IDS" ]]; then
        WINDOW_IDS=$(<<< "$WINDOWS" jq '.[] | select(.app=="'"$APP"'") | .id')
        if [[ -z "$WINDOW_IDS" ]]; then
            MESSAGE="$APP"
            echo "[-] $MESSAGE"
            return 1
        fi
    fi

    # Cache the JSON blob for the specified display.
    DISPLAY=$(<<< "$DISPLAYS" jq ".[$REL_DISP_INDEX]")

    # Resolve absolute display and space indices.
    ABS_DISP_INDEX=$(get_display_index)
    ABS_SPACE_INDEX=$(get_space_index "$REL_SPACE_INDEX")

    # Bail if the window is already in the right location.
    MOVE='false'
    for WINDOW_ID in $WINDOW_IDS; do
        LOC=$(<<< "$WINDOWS" jq -j '.[] | select(.id == '"$WINDOW_ID"') | .space, ":", .display, "\n"' | sort -u)
        DEST="$ABS_SPACE_INDEX:$ABS_DISP_INDEX"
        if [[ "$LOC" != "$DEST" ]]; then
            MOVE='true'
            echo "[*] $LOC ⮕ $DEST"
        fi
    done
    if [[ "$MOVE" == 'false' ]]; then
        echo "[+] $APP"
        return
    fi

    # Create the space if it doesn't already exist.
    if [[ "$ABS_SPACE_INDEX" == 'null' ]]; then
        MESSAGE="Creating extra space on display $ABS_DISP_INDEX"
        echo "[*] $MESSAGE"
        notify "$MESSAGE"
        yabai -m display --focus "$ABS_DISP_INDEX"
        yabai -m space --create

        # Refresh cached JSON blobs to reflect newly created space.
        DISPLAYS=$(get_displays)
        DISPLAY=$(<<< "$DISPLAYS" jq ".[$REL_DISP_INDEX]")
        ABS_SPACE_INDEX=$(get_space_index "$REL_SPACE_INDEX")
    fi

    # Finally, move windows.
    MESSAGE="$APP ⮕ space $ABS_SPACE_INDEX, display $ABS_DISP_INDEX"
    echo "[+] $MESSAGE"
    notify "$MESSAGE"
    for ID in $WINDOW_IDS; do
        yabai -m window "$ID" --space "$ABS_SPACE_INDEX"
    done
}

# Cache displays and windows blobs.
DISPLAYS=$(get_displays)
WINDOWS=$(get_windows)

# Get Firefox window IDs grouped by profile.
FIREFOX_PROFILES=$(
    <<< "$WINDOWS" jq '.[] | select(.app == "Firefox") | .id, " ", .pid, "\n"' -j |
    while read WID PID; do
        PROFILE=$(ps -p "$PID" | grep 'firefox' | sed -E 's/.*-P ([^ ]+).*/\1/')
        jq -n --arg 'profile' "$PROFILE" --arg 'wid' "$WID" '{"profile": ($profile), "id": $wid}'
    done |
    jq -s 'reduce .[] as $window ({};
           if has($window.profile)
           then .[($window.profile)] += [$window.id]
           else . + {($window.profile): [$window.id]}
           end)'
)

# Get Teams meeting window ID. Uses the heuristic that of all windows having
# "| Microsoft Teams" in the title, the meeting will have been created most
# recently, and will therefore have the highest window ID.
TEAMS_WINDOWS=$(<<< "$WINDOWS" jq '.[] | select(.title | index(" | Microsoft Teams")) | .id' | sort -n)
TEAMS_MAIN=$(<<< "$TEAMS_WINDOWS" head -n 1)
if [[ $(<<< "$TEAMS_WINDOWS" wc -l | tr -d ' \n') -gt 1 ]]; then
    TEAMS_MEETING=$(<<< "$TEAMS_WINDOWS" tail -n 1)
fi

# Get Slack call window ID.
SLACK_CALL=$(<<< "$WINDOWS" jq -r '.[] | select(.title | test("Slack \\| .* \\| [0-9]+:[0-9]+")) | .id')

# Display initial notififcation. Useful to ensure that the script is running
# when there aren't any windows that need moving (i.e., when there aren't any
# further notifications).
notify 'Organizing windows...'

# Move windows.
# move_window 'Firefox (Work)'          0 0 "$(<<< "$FIREFOX_PROFILES" jq -r '.Work     | @tsv')"
# move_window 'Firefox (Personal)'      2 0 "$(<<< "$FIREFOX_PROFILES" jq -r '.Personal | @tsv')"
move_window 'Firefox'                 0 0
move_window 'Chromium'                1 0
move_window 'Burp Suite Professional' 1 0
move_window 'Ghidra'                  1 0
move_window 'Preview'                 1 0
move_window 'Skim'                    1 0
move_window 'Google Chrome'           2 0
move_window 'VMware Fusion'           3 0
move_window 'VirtualBox VM'           3 0
move_window 'VirtualBox'              3 0

# If a second display is attached, then change the space offset and display
# accordingly.
if [[ $(<<< "$DISPLAYS" jq 'length') == 2 ]]; then
    DISPLAY_INDEX='1'
    SPACE_INDEX_OFFSET='0'
else
    DISPLAY_INDEX='0'
    SPACE_INDEX_OFFSET='4'
fi
move_window 'Microsoft Outlook'         $((SPACE_INDEX_OFFSET + 0)) "$DISPLAY_INDEX"
move_window 'Microsoft Teams (Main)'    $((SPACE_INDEX_OFFSET + 1)) "$DISPLAY_INDEX" "$TEAMS_MAIN"
move_window 'Slack'                     $((SPACE_INDEX_OFFSET + 2)) "$DISPLAY_INDEX"
move_window 'Microsoft Teams (Meeting)' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$TEAMS_MEETING"
move_window 'Slack (Call)'              $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$SLACK_CALL"
move_window 'zoom.us'                   $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX"
