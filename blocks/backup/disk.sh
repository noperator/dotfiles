#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"

USAGE=$(df -h | grep '/dev/sda1' | awk '{print $4}')

echo "💾 $USAGE"
echo "💾 $USAGE"
echo
