#!/bin/bash

for APP in \
'Burp Suite Professional' \
'Microsoft Outlook' \
'Microsoft Teams' \
Slack \
; do
    open -a "$APP"
done
