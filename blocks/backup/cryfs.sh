#!/usr/bin/env bash

source "$(dirname $0)/_colors.sh"

if [[ `grep cryfs /proc/mounts` ]]; then
#   echo "${BOLD}📂${NORMAL}"
#   echo "${BOLD}📂${NORMAL}"
  echo "📂"
  echo "📂"
  echo "$RED"
else
  echo '📁'
  echo '📁'
  echo "$BLACK"
fi
