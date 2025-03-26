#!/usr/bin/env bash

source "$(dirname $0)/_functions.sh"

# ----------------------------------------------
# Create/destroy spaces as needed, depending on connected displays.
# ----------------------------------------------

LAYOUTS=$(
    jo -a \
        $(
            jo -a \
                $(
                    jo display=1 spaces=9
                )
        ) \
        $(
            jo -a \
                $(
                    jo display=1 spaces=4
                ) \
                $(
                    jo display=2 spaces=5
                )
        ) \
        $(
            jo -a \
                $(
                    jo display=1 spaces=3
                ) \
                $(
                    jo display=2 spaces=1
                ) \
                $(
                    jo display=3 spaces=4
                )
        )
)

notify 'Balancing spaces…'
export DISPLAYS=$(get_displays)
diff-layout "$LAYOUTS"

# ----------------------------------------------
# Make sure some apps are actually showing/visible.
# ----------------------------------------------

# notify 'Showing windows…'
# VIS=$(get-visible-spaces)
# for APP in \
#     "Slack" \
#     "Microsoft Outlook" \
#     "Google Chrome" \
#     "Microsoft Teams"; do
#     show-app "$APP"
# done
# sleep .4
# focus-spaces "$VIS"

# ----------------------------------------------
# Move windows to correct spaces.
# ----------------------------------------------

# Cache displays and windows blobs again, in case changed above.
export DISPLAYS=$(get_displays)
export WINDOWS=$(get_windows)

# Display initial notififcation. Useful to ensure that the script is running
# when there aren't any windows that need moving (i.e., when there aren't any
# further notifications).
notify 'Organizing windows…'

hs -c 'moveAppWindowsToSpace("Slack", 2)'
hs -c 'moveAppWindowsToSpace("Signal", 2)'

# If a second display is attached, then change the space offset and display
# accordingly.
if [[ $(jq <<<"$DISPLAYS" 'length') -eq 2 ]]; then
    DISPLAY_INDEX='1'
    SPACE_INDEX_OFFSET='0'
else
    DISPLAY_INDEX='0'
    SPACE_INDEX_OFFSET='4'
fi

# move_window 'Arc' $((SPACE_INDEX_OFFSET + 2)) $DISPLAY_INDEX
hs -c 'moveAppWindowsToSpace("Arc", 7)'
