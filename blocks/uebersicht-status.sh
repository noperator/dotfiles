#!/bin/bash

# set -x

PATH="/opt/homebrew/bin:$PATH"
DIRNAME=$(dirname "$0")

# python3 "$DIRNAME/notch.py"
# cat "$DIRNAME/1.txt" | tr -d '\n'
# exit

mkdir -p -m 700 /var/tmp/blocks

# Check if Slack or Teams are screen sharing.
screen_sharing() {
    if [[ $(yabai -m query --windows 2>/dev/null |
        jq -r '[.[] | select(.app      == "Slack" and
                                 .floating == 1       and
                                 .frame.w  == 400     and
                                 .frame.h  == 56)] | length') -gt 0 ]]; then
        echo '@exclamation-triangle@ @desktop@ Slack  '
    elif pgrep -alf '\-msteams-process-type=appSharingToolbar' | grep -v 'pgrep' >>/var/tmp/blocks/teams-ps.txt 2>&1; then
        echo '@exclamation-triangle@ @desktop@ Teams  '
    else
        false
    fi
}

# touch /var/tmp/blocks/ipv4-hash-new.txt
mv /var/tmp/blocks/ipv4-hash-new.txt /var/tmp/blocks/ipv4-hash-old.txt 2>/dev/null
cat /var/tmp/blocks/ipv4-{pub,wif,eth}.txt 2>/dev/null | sort | shasum | cut -f 1 -d ' ' >/var/tmp/blocks/ipv4-hash-new.txt

(
    # Only display networking information if not screen sharing.
    if ! screen_sharing; then
        # speed \
        # vpn \
        for SCRIPT in \
            timer \
            public-ip \
            gateway \
            wifi \
            ethernet; do
            "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
        done
    fi

    # These items don't contain sensitive information.
    # airpods \
    # trackpad \
    for SCRIPT in \
        battery \
        date; do
        "$DIRNAME/${SCRIPT}.sh" | tr '\n' ' '
    done
) | sed -E 's/ +/ /g'

# set +x
