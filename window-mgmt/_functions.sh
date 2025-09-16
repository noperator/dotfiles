#!/usr/bin/env bash

alias yabai=/opt/homebrew/bin/yabai
get_displays() { yabai -m query --displays; }
get_windows() { yabai -m query --windows; }
notify() { osascript -e 'display notification "'"$1"'" with title "'"Auto Window"'"'; }

# https://talk.macpowerusers.com/t/automating-spaces-in-mission-control/30877/16
# @param $1 List of displays along with how many spaces should be created or
#           destroyed. In the following example:
#           - Display 1 should remove 6 spaces
#           - Display 2 should add 8 spaces
#           - Display 3 is fine as is
#           ```
#           {{1,-6},{2,8},{3,0}}
#           ```
balance_displays() {
    osascript <<EOD
set layoutDiff to $1
tell application "Mission Control" to launch
delay 0.5
tell application "System Events"
    repeat with displayDiff in layoutDiff
        copy displayDiff to {display, spaces}

        -- Remove spaces.
        if spaces is less than 0 then
            tell list 1 of group 2 of group display of group 1 of process "Dock"
                repeat -spaces times
                	perform action "AXRemoveDesktop" of button (count of buttons)
                end repeat
            end tell
    
        -- Add spaces.
        else if spaces is greater than 0 then
            tell group 2 of group display of group 1 of process "Dock"
                repeat spaces times
                    click (every button whose value of attribute "AXDescription" is "add desktop")
                end repeat
            end tell
        end if
    
    end repeat
    delay 0.25
    key code 53
end tell
EOD
}

diff-layout() {
    LAYOUTS="$1"

    if [[ -z "$DISPLAYS" ]]; then
        DISPLAYS=$(get_displays)
    fi

    LAYOUT_DIFF=$(echo "$LAYOUTS" | jq -rc --argjson displays "$DISPLAYS" 'map(select(length == ($displays | length)) | map(to_entries | map(.value))[] | @tsv)[]' |
        while read DISP_IDX DESIRED_SPACES; do
            ACTUAL_SPACES=$(jq <<<"$DISPLAYS" -r --arg disp "$DISP_IDX" 'map(select(.index == ($disp | tonumber)))[] | .spaces | length')
            jo -a "$DISP_IDX" $((DESIRED_SPACES - ACTUAL_SPACES))
        done | jo -a | jq -c 'map(select(.[1] != 0))')

    if [[ $(echo "$LAYOUT_DIFF" | jq length) -gt 0 ]]; then
        balance_displays $(echo "$LAYOUT_DIFF" | sed -E 's/\[/{/g; s/\]/}/g')
    fi
}

# https://apple.stackexchange.com/a/36947
declare -A SPACES
SPACES[1]=18
SPACES[2]=19
SPACES[3]=20
SPACES[4]=21
SPACES[5]=23
SPACES[6]=22
SPACES[7]=26
SPACES[8]=28
SPACES[9]=25
SPACES[0]=29

# Generate an AppleScript that can be passed to `osascript` for execution.
# @param $@ List of space-delimited Mission Control space identifiers that
#           should be switched to.
osa-focus-spaces() {
    echo 'tell application "System Events"'
    for SPACE in $@; do
        echo "key code ${SPACES[$SPACE]} using command down"
        echo 'delay 0.4' # Seems to be the shortest acceptable delay.
    done
    echo 'end tell'
}

focus-spaces() {
    osa-focus-spaces $@ | osascript
}

get-visible-spaces() {
    yabai -m query --spaces | jq -r 'map(select(.["is-visible"]) | .index) | @tsv'
}

# https://github.com/koekeishiya/yabai/issues/259#issuecomment-865056633
get-layout() {
    yabai -m query --windows |
        jq -r '.[] | select(.minimized != 1) | "yabai -m window \(.id) --display \(.display) --space \(.space) --move abs:\(.frame.x):\(.frame.y) --resize abs:\(.frame.w):\(.frame.h)"'
}

restart-win-mgmt() {

    # Start SwitchResX daemon.
    if ! pgrep -f 'SwitchResX Daemon.app' &>/dev/null; then
        notify 'Starting SwitchResX Daemon…'
        open "$HOME/Library/PreferencePanes/SwitchResX.prefPane/Contents/PlugIns/SwitchResX Daemon.app"
    fi

    # Save currently visible spaces so we can return back to them later.
    #
    # TODO: Save window arrangement, too.
    # VIS=$(get-visible-spaces)
    # LAY=$(get-layout)

    # Restart yabai, and cycle through all spaces so that the spaces in those
    # windows will have their `(first|last)-window` keys will be populated.
    #
    # TODO: For some reason, Outlook sometimes still isn't registered after a
    # restart, unless I'm currently focused on the space where it's located.
    # Possibly move all windows to the focused space before restart, and then
    # reorganize after? That seems extreme.
    notify 'Restarting yabai…'
    # brew services restart yabai
    yabai --restart-service
    # while ! pgrep yabai &>/dev/null; do
    while [[ $(yabai -m query --windows |& grep -c 'failed to connect to socket') == 1 ]]; do
        sleep .25
    done
    # sleep 1
    # notify 'Focusing spaces…'
    # notify 'Registering windows…'
    # focus-spaces $(yabai -m query --spaces | jq -r 'map(.index) | sort | @tsv')

    # Finally, return back to the previously visible spaces.
    # focus-spaces "$VIS"
    # # echo "$LAY" | bash

    # TODO: Factor the organize windows logic out more cleanly.
    # notify 'Organizing windows…'
    # "$(dirname $0)/organize-windows.sh"
    # ~/dotfiles/window-mgmt/organize-windows.sh

    # Refresh Uebersicht widgets (to update space indicators).
    osascript -e 'tell application id "tracesOf.Uebersicht" to refresh'
    notify 'Refreshing widgets…'
}

move-window() {

    # Attributes of the window we want to reposition.
    APP="$1"   # APP='Microsoft Outlook'
    TITLE="$2" # TITLE='Reminder'

    # Display that the window should be on.
    DISP_NUM="$3" # DISP_NUM=1

    # Intended right/bottom margin, in pixels, of the repositioned window.
    MARGIN="$4" # MARGIN=20

    # Save the currently focused window so we can restore focus later.
    PREV_WIN_ID=$(yabai -m query --windows --window | jq -r .id)

    # Attempt to focus on the window, assuming it exists, etc. We use AppleScript
    # to focus instead of yabai, because of an issue (either in yabai or macOS API,
    # not quite sure) where yabai can't see some windows (unless it's already
    # focused on that window).
    # - https://github.com/koekeishiya/yabai/issues/1615
    #
    # Note that if the main Outlook window is already in focus, then AppleScript
    # has a hard time focusing specifically on the Reminder window, since
    # `activate` raises _all_ windows; it doesn't seem to be possible to use
    # AppleScript to activate a specific window of an application.
    osascript -e "activate first window of application \"$APP\" whose name contains \"$TITLE\""
    #     osascript <<EOD
    # repeat with w in (windows of application "$APP")
    #     if (name of w) contains "$TITLE"
    #         # set bounds of w to {9999, 0, 9999, 0}
    #         activate w
    #     end if
    # end repeat
    # EOD

    # As a last-ditch effort, just in case yabai happens to be able to see the
    # window, try to use yabai to focus on it.
    yabai -m window --focus $(osascript -e "get id of first window of application \"$APP\" whose name contains \"$TITLE\"")

    WIN=$(yabai -m query --windows --window)
    if [[ $(echo "$WIN" | jq --arg app "$APP" --arg title "$TITLE" \
        '.app == $app and (.title | index($title))') == 'true' ]]; then

        DISP=$(yabai -m query --displays --display "$DISP_NUM")
        DW=$(jq -r .frame.w <<<"$DISP")
        DH=$(jq -r .frame.h <<<"$DISP")
        WW=$(jq -r .frame.w <<<"$WIN")
        WH=$(jq -r .frame.h <<<"$WIN")
        yabai -m window --display "$DISP_NUM"
        yabai -m window --move abs:$((DW - WW - MARGIN)):$((DH - WH - MARGIN))
    fi

    # Restore focus to the previously focused window.
    yabai -m window --focus "$PREV_WIN_ID"
}

# If an application is open (i.e., it has an icon in the Dock) but there's no
# visible window, click on the Dock icon to make a window appear.
# @param $1 Name of already open application that should be visible.
show-app() {
    APP="$1"
    if [[ $(yabai -m query --windows |
        jq --arg app "$APP" 'map(select(.app == $app and .["is-floating"] == false)) | length') == 0 ]]; then
        osascript <<EOD
tell application "System Events"
        tell list 1 of application process "Dock"
            repeat with uie in (every UI Element whose subrole is "AXApplicationDockItem")
                if (name of uie) is "$APP"
                    click uie
                end if
            end repeat
        end tell
end tell
EOD
    fi
}

dezoom() {
    yabai -m query --windows |
        gojq 'map(select(to_entries | map(select(.key | test("zoom")) | .value) | index(true)) | with_entries(select(.key | test("zoom$|^id"))))' |
        jq -r 'map(to_entries | map(.value) | @tsv)[]' |
        while read FULLSCR PARENT WID; do
            if [[ "$FULLSCR" == 'true' ]]; then
                yabai -m window "$WID" --toggle zoom-fullscreen
            elif [[ "$PARENT" == 'true' ]]; then
                yabai -m window "$WID" --toggle zoom-parent
            fi
        done
}

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
move_window() {
    APP="$1"
    REL_SPACE_INDEX="$2"
    REL_DISP_INDEX="$3"
    WINDOW_IDS="$4"

    if [[ -z "$DISPLAYS" ]]; then
        DISPLAYS=$(get_displays)
    fi
    if [[ -z "$WINDOWS" ]]; then
        WINDOWS=$(get_windows)
    fi

    # Get windows IDs associated with the application name, and bail if none
    # exist.
    if [[ -z "$WINDOW_IDS" ]]; then
        WINDOW_IDS=$(jq <<<"$WINDOWS" '.[] | select(.app=="'"$APP"'") | .id')
        if [[ -z "$WINDOW_IDS" ]]; then
            MESSAGE="$APP"
            echo "[-] $MESSAGE"
            return 1
        fi
    fi

    # Cache the JSON blob for the specified display.
    DISPLAY=$(jq <<<"$DISPLAYS" ".[$REL_DISP_INDEX]")

    # Resolve absolute display and space indices.
    # get_display_index() { jq <<<"$DISPLAY" '.index'; }
    # get_space_index() { jq <<<"$DISPLAY" ".spaces[$1]"; }
    # ABS_DISP_INDEX=$(get_display_index)
    # ABS_SPACE_INDEX=$(get_space_index "$REL_SPACE_INDEX")
    ABS_DISP_INDEX=$(jq <<<"$DISPLAY" '.index')
    ABS_SPACE_INDEX=$(jq <<<"$DISPLAY" --arg i "$REL_SPACE_INDEX" '.spaces[($i | tonumber)]')

    # Bail if the window is already in the right location.
    MOVE='false'
    for WINDOW_ID in $WINDOW_IDS; do
        LOC=$(jq <<<"$WINDOWS" -j '.[] | select(.id == '"$WINDOW_ID"') | .space, ":", .display, "\n"' | sort -u)
        DEST="$ABS_SPACE_INDEX:$ABS_DISP_INDEX"
        if [[ "$LOC" != "$DEST" ]]; then
            MOVE='true'
            echo "[*] $LOC ⮕  $DEST"
        fi
    done
    if [[ "$MOVE" == 'false' ]]; then
        echo "[+] $APP"
        return
    fi

    # Finally, move windows.
    MESSAGE="$APP ⮕ space $ABS_SPACE_INDEX, display $ABS_DISP_INDEX"
    echo "[+] $MESSAGE"
    # notify "$MESSAGE"
    for ID in $WINDOW_IDS; do
        yabai -m window "$ID" --space "$ABS_SPACE_INDEX"
    done
}
