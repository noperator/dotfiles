#!/bin/bash

# This script watches macOS logs for events that I've determined, through trial
# and error, are heuristically associated with the YubiKey waiting for touch. I
# primarily use the FIDO2 and OpenPGP features and haven't tested other
# applications listed in `ykman info` (e.g., Yubico OTP, FIDO U2F, OATH, PIV,
# YubiHSM Auth).
#
# When waiting for FIDO2 touch, we'll see this message logged once:
# kernel: (IOHIDFamily) IOHIDLibUserClient:0x100543841 startQueue
#
# When waiting for OpenPGP touch, we'll see this message logged repeatedly:
# usbsmartcardreaderd: [com.apple.CryptoTokenKit:ccid] Time extension received
#
# As soon as the YubiKey is touched, we'll get a new/different log message in
# the same category. So the strategy here is to check if either of the above
# messages are the last one logged in their respective categories, and if so,
# notify the user to touch the YubiKey.

PATH="/opt/homebrew/bin:$PATH"
LOG_FILE="$HOME/tmp/yklogs.jsonl"

notify() { osascript -e 'display notification "'"$1"'" with title "'"YubiKey Helper"'"'; }

while true; do
    if cat "$LOG_FILE" |
        jq -r 'select(.processImagePath == "/kernel" and (.senderImagePath | test("IOHIDFamily$"))) | .eventMessage' |
        tail -n 1 |
        grep -qE 'IOHIDLibUserClient.*startQueue'; then
        notify 'Touch Yubikey (FIDO2)'
    elif cat "$LOG_FILE" |
        jq -r 'select((.processImagePath | test("usbsmartcardreaderd$")) and (.subsystem | test("CryptoTokenKit$"))) | .eventMessage' |
        tail -n 1 |
        grep -q 'Time extension received'; then
        notify 'Touch Yubikey (OpenPGP)'
    fi
    sleep 1
done &

log stream --level debug --style ndjson |
    jq -c --unbuffered 'select(
        (
            .processImagePath == "/kernel" and
            .senderImagePath == "/System/Library/Extensions/IOHIDFamily.kext/Contents/MacOS/IOHIDFamily"
        ) or
        (
            .processImagePath == "/System/Library/CryptoTokenKit/usbsmartcardreaderd.slotd/Contents/MacOS/usbsmartcardreaderd" and
            .subsystem == "com.apple.CryptoTokenKit"
        )
    )' \
        >"$LOG_FILE"
