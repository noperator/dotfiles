#!/bin/bash

which nvim &>/dev/null && alias vim='nvim'
v() {
    FILE='-'
    ! [[ -z "$1" ]] && FILE="$1"
    vim "$FILE"
}
vr() {
    FILE='-'
    ! [[ -z "$1" ]] && FILE="$1"
    vim -R "$FILE"
}
vt() {
    case "$OSTYPE" in
    'darwin'*) # macOS does not honor TMPDIR or allow suffixes.
        TEMP="$(mktemp ${TMPDIR}markdown.XXXXXXXXXX)"
        rm "$TEMP"
        TEMP_MD="$TEMP.md"
        ;;
    'linux-gnu'*)
        if [[ -d "$HOME/tmp" ]]; then
            TEMP_MD="$(mktemp -p "$HOME/tmp" markdown.XXXXXXXXXX.md)"
        else
            TEMP_MD="$(mktemp -t markdown.XXXXXXXXXX.md)"
        fi
        ;;
    esac
    touch "$TEMP_MD"
    echo "$TEMP_MD"
    tp "$TEMP_MD" &
    vim "$TEMP_MD"
}

sl() {
    # sed -E 's/^\s+//' |
    fc -ln -1 |
        sol $@ |
        bat -l sh --style grid
}

se() {
    fc -e "vim -c \":%!sol $@\"" -1
}

# Find undone TODO items in note-y files.
# Note: not currently using MATCH_RE.
todo() {
    echo '
^(notes|thoughts|questions):@^ *- +[^[]
^(#+ )?to.?do@^ *- +[ ]
' | grep -vE '^$' | while IFS=@ read TYPE_RE MATCH_RE; do
        echo -e "\n# === \`$TYPE_RE\` ===\n" # ========================================"

        ls {notes,README}.{md,txt} 2>/dev/null | while read FILE; do
            OUT=$(
                cat "$FILE" | awk -v type_re="$TYPE_RE" -v match_re="$MATCH_RE" '
            BEGIN {todo = 0; since = 0}
            {
                since += 1;
                if ($1 ~ /^[0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}Z/) {print "\n###", $0};
                if (since > 1 && $0 == "") {todo = 0; since = 0};
                if (todo == 1 && $0 ~ /^ *- /) {print $0};
                # if (todo == 1 || $0 ~ /^ *- +\[ \]/) {print $0};
                if (tolower($0) ~ type_re) {todo = 1; since = 0};
            }
            '
            )
            CLEAN=$(echo -n "$OUT" | grep -vE '^(\s+|#.*|)$' | wc -l | tr -d ' ')
            if [[ "$CLEAN" -gt 0 ]]; then
                echo -e "\n## \`$FILE\`\n" # --------------------"
                echo "$OUT"
            fi
        done
    done |
        while IFS= read LINE; do
            # `todo -a` shows completed items.
            if [[ "$1" != '-a' ]]; then
                echo "$LINE" | grep -vE '\[[^ ]\]'
            else
                echo "$LINE"
            fi
        done |
        while IFS= read LINE; do

            # This is all basically to hide timestamp headers that aren't
            # followed by any content.
            if [[ "$LINE" =~ ^# ]]; then
                TS=""
            fi
            if [[ "$LINE" =~ ^#{3}\ [0-9]{4}(-[0-9]{2}){2}T[0-9]{2}(:[0-9]{2}){2}Z ]]; then
                LAST_TS=true
                TS="$LINE"
                continue
            elif [[ -z "$LINE" ]]; then
                echo "$LINE"
                continue
            fi
            if [[ "$LAST_TS" == 'true' ]]; then
                echo -e "$TS\n"
                LAST_TS=false
            fi
            echo "$LINE"

        done |
        cat -s |
        bat -l md --paging never --style plain
}

cursor() {
    /Applications/Cursor.app/Contents/MacOS/Cursor "$1" &>/dev/null &
}

code() {
    "/Applications/Visual Studio Code.app/Contents/MacOS/Electron" "$1" &>/dev/null &
}
