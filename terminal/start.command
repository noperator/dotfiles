#!/bin/bash

for APP in \
'Microsoft Outlook' \
'Microsoft Teams' \
Slack \
; do
    open -a "$APP"
done
