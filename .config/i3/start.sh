#!/bin/bash

DATETIME=$(date -uIseconds | sed -E 's/\+00:00/Z/')
i3 &>> "$HOME/.config/i3/$DATETIME.log"
