#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"

BATT=$(acpi -b | awk '{s+=$4; i+=1} END {print int(s/i)}')

if [[ `acpi -a | grep 'on-line'` ]]; then
  echo "⚡ $BATT%"
  echo "⚡ $BATT%"
  echo
else
  echo "🔋 $BATT%"
  echo "🔋 $BATT%"
  if [[ "$BATT" -lt 10 ]]; then
    echo "$RED"
  elif [[ "$BATT" -lt 20 ]]; then
    echo "$YELLOW"
  else
    echo
  fi
fi


