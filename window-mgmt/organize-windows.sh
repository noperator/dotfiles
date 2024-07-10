#!/usr/bin/env bash

source "$(dirname $0)/_functions.sh"

# ----------------------------------------------
# Create/destroy spaces as needed, depending on connected displays.

LAYOUTS=$(
    jo -a \
        $(
            jo -a \
                $(
                    jo display=1 spaces=8
                )
        ) \
        $(
            jo -a \
                $(
                    jo display=1 spaces=4
                ) \
                $(
                    # jo display=2 spaces=4
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

notify '(3/5) Balancing spaces…'
export DISPLAYS=$(get_displays)
diff-layout "$LAYOUTS"

# ----------------------------------------------
# Move some tricky floating windows around.

# TODO: Only run the line below if Outlook is already running. (Otherwise, it
# _starts_ Outlook.)
# move-window 'Microsoft Outlook' 'Reminder' 1 20

# ----------------------------------------------
# Make sure some apps are actually showing/visible.

notify '(4/5) Showing windows…'
VIS=$(get-visible-spaces)
for APP in \
    "Slack" \
    "Microsoft Outlook" \
    "Google Chrome" \
    "Microsoft Teams"; do
    show-app "$APP"
done
sleep .4
focus-spaces "$VIS"

# ----------------------------------------------
# Move windows to correct spaces.

# Cache displays and windows blobs again, in case changed above.
export DISPLAYS=$(get_displays)
export WINDOWS=$(get_windows)

# Get Firefox window IDs grouped by profile.
FIREFOX_PROFILES=$(
    jq <<<"$WINDOWS" '.[] | select(.app == "Firefox") | .id, " ", .pid, "\n"' -j |
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
# TEAMS_WINDOWS=$(jq <<<"$WINDOWS" '.[] | select(.app == "Microsoft Teams" and (.title | index("Shared content") | not) and (.title | index("Notification") | not)) | .id' | sort -n)
TEAMS_WINDOWS=$(jq <<<"$WINDOWS" '.[] | select((.app | test("^Microsoft Teams")) and (.title | index("Shared content") | not) and (.title | index("Notification") | not)) | .id' | sort -n)
TEAMS_MAIN=$(head <<<"$TEAMS_WINDOWS" -n 1)
if [[ $(wc <<<"$TEAMS_WINDOWS" -l | tr -d ' \n') -gt 1 ]]; then
    TEAMS_MEETING=$(tail <<<"$TEAMS_WINDOWS" -n 1)
    #  TEAMS_MEETING=$(jq -c 'select(.title | index("Shared content") | not)' <<<"$TEAMS_WINDOWS" | tail -n 1)
fi

# Get Slack call window ID.
# SLACK_CALL=$(jq <<<"$WINDOWS" -r '.[] | select(.title | test("Slack \\| .* \\| [0-9]+:[0-9]+")) | .id')
# 	"title":"Huddle: team-seedy - Bishop Fox - Slack",
SLACK_CALL=$(jq <<<"$WINDOWS" -r '.[] | select(.title | test("Huddle:.*Slack")) | .id')

# Get Slack post window ID.
SLACK_POST=$(jq <<<"$WINDOWS" -r '.[] | select(.title | test("Slack \\| [^\\|]+$")) | .id')

# Get Chrome window IDs.
SLACK_POST=$(jq <<<"$WINDOWS" -r '.[] | select(.title | test("Slack \\| [^\\|]+$")) | .id')
CHROME_WINDOWS=$(jq <<<"$WINDOWS" -r '.[] | select(.app == "Google Chrome") | [.id, .pid] | @tsv')
get_chrome_window() {
    echo "$CHROME_WINDOWS" | while read WID WPID; do
        PROFILE=$($(which ps) -p "$WPID" -o 'command=' | sed -E 's/.*user-data-dir=.*chrome-(Work|Home).*/\1/')
        [[ "$PROFILE" == "$1" ]] && echo "$WID"
    done
}
CHROME_WORK=$(get_chrome_window 'Work')
CHROME_HOME=$(get_chrome_window 'Home')

# TEAMS_SHARED=$(jq <<<"$WINDOWS" -r 'map(select(.app == "Microsoft Teams" and (.title | test("Shared content"))))[] | .id')
TEAMS_SHARED=$(jq <<<"$WINDOWS" -r 'map(select((.app | test("^Microsoft Teams")) and (.title | test("Shared content"))))[] | .id')

# SLACK_HUDDLE=$(jq <<<"$WINDOWS" -r 'map(select(.app == "Slack" and (.title | test("^Slack.*Huddle$"))))[] | .id')
SLACK_HUDDLE=$(jq <<<"$WINDOWS" -r 'map(select(.app == "Slack" and (.title | test("Huddle: .* Slack.*"))))[] | .id')

# Display initial notififcation. Useful to ensure that the script is running
# when there aren't any windows that need moving (i.e., when there aren't any
# further notifications).
notify '(5/5) Organizing windows...'

# Move windows.
# move_window 'Firefox (Work)'          0 0 "$(<<< "$FIREFOX_PROFILES" jq -r '.Work     | @tsv')"
# move_window 'Firefox (Personal)'      2 0 "$(<<< "$FIREFOX_PROFILES" jq -r '.Personal | @tsv')"
move_window 'Firefox' 0 0
# move_window 'Chromium'                1 0
move_window 'Burp Suite Professional' 1 0
move_window 'Ghidra' 1 0
move_window 'Preview' 1 0
move_window 'Skim' 1 0
move_window 'GIMP-2.10' 1 0
move_window 'Microsoft Word' 1 0
move_window 'Microsoft PowerPoint' 1 0
move_window 'Slack (Post)' 1 0 "$SLACK_POST"
move_window 'Google Chrome (Work)' 0 0 "$CHROME_WORK"
move_window 'Google Chrome (Home)' 2 0 "$CHROME_HOME"
move_window 'Arc' 2 0
# move_window 'VMware Fusion' 3 0
# move_window 'VirtualBox VM' 3 0
# move_window 'VirtualBox' 3 0

# If a second display is attached, then change the space offset and display
# accordingly.
if [[ $(jq <<<"$DISPLAYS" 'length') -ge 2 ]]; then
    DISPLAY_INDEX='1'
    SPACE_INDEX_OFFSET='0'
else
    DISPLAY_INDEX='0'
    SPACE_INDEX_OFFSET='4'
fi
move_window 'Microsoft Outlook' $((SPACE_INDEX_OFFSET + 0)) "$DISPLAY_INDEX"
move_window 'Microsoft Teams (Main)' $((SPACE_INDEX_OFFSET + 1)) "$DISPLAY_INDEX" "$TEAMS_MAIN"
move_window 'Slack' $((SPACE_INDEX_OFFSET + 2)) "$DISPLAY_INDEX"
move_window 'Slack (Call)' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$SLACK_CALL"
move_window 'zoom.us' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX"

if [[ $(jq <<<"$DISPLAYS" 'length') -gt 2 ]]; then
    DISPLAY_INDEX='0'
    SPACE_INDEX_OFFSET='-3'
fi
move_window 'Microsoft Teams (Shared)' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$TEAMS_SHARED"

if [[ $(jq <<<"$DISPLAYS" 'length') -gt 2 ]]; then
    DISPLAY_INDEX='2'
    SPACE_INDEX_OFFSET='-3'
fi
move_window 'Microsoft Teams (Meeting)' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$TEAMS_MEETING"
move_window 'Slack (Huddle)' $((SPACE_INDEX_OFFSET + 3)) "$DISPLAY_INDEX" "$SLACK_HUDDLE"

# shared content window
# 𝄢 yabai -m query --windows | g shared
# 	"title":"Shared content | Seedy Trunk | Microsoft Teams",

# meeting window while not sharing
# 𝄢 yabai -m query --windows | g trunk
# 	"title":"Seedy Trunk | Microsoft Teams",
