#!/bin/bash

alias yabai=/usr/local/bin/yabai
get_displays() { yabai -m query --displays; }
get_windows()  { yabai -m query --windows;  }
get_display_index() { echo "$DISPLAY" | jq '.index';      }
get_space_index()   { echo "$DISPLAY" | jq ".spaces[$1]"; }

# This function takes relative space/display arrangement indices, determines
# the absolute index for those values, and moves windows accordingly.
# For example:
# - "move_window Firefox 0 0" = Move Firefox to the first space on the first  display
# - "move_window Slack   2 1" = Move Slack   to the third space on the second display
# $1: Application name
# $2: Relative space index
# $3: Relative display index
move_window()
{
    APP="$1"
    REL_SPACE_INDEX="$2"
    REL_DISP_INDEX="$3"
    
    # Get windows IDs associated with the application name, and bail if none exist.
    WINDOW_IDS=$(echo "$WINDOWS" | jq '.[] | select(.app=="'"$APP"'") | .id')
    if [[ -z "$WINDOW_IDS" ]]; then
        echo "[-] Window not found for app $APP."
    else

        # Cache the JSON blob for the specified display.
        DISPLAY=$(echo "$DISPLAYS" | jq ".[$REL_DISP_INDEX]")

        # Resolve absolute display and space indices.
        ABS_DISP_INDEX=$(get_display_index)
        ABS_SPACE_INDEX=$(get_space_index "$REL_SPACE_INDEX")

        # Create the space if it doesn't already exist.
        if [[ "$ABS_SPACE_INDEX" == 'null' ]]; then
            echo "[*] Creating extra space on display $ABS_DISP_INDEX"
            yabai -m display --focus "$ABS_DISP_INDEX"
            yabai -m space --create

            # Refresh cached JSON blobs to reflect newly created space.
            DISPLAYS=$(get_displays)
            DISPLAY=$(echo "$DISPLAYS" | jq ".[$REL_DISP_INDEX]")
            ABS_SPACE_INDEX=$(get_space_index "$REL_SPACE_INDEX")
        fi

        # Finally, move windows.
        echo "[+] Moving $APP to space $ABS_SPACE_INDEX on display $ABS_DISP_INDEX"
        for ID in $WINDOW_IDS; do
            yabai -m window "$ID" --space "$ABS_SPACE_INDEX"
        done
    fi
}

# Cache displays and windows blobs.
DISPLAYS=$(get_displays)
WINDOWS=$(get_windows)

# Move windows.
move_window Firefox 0 0
move_window 'Google Chrome' 1 0
move_window 'Burp Suite Professional' 1 0
move_window 'Microsoft Outlook' 0 1
move_window 'Microsoft Teams' 1 1
move_window Slack 2 1
