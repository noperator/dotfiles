#!/usr/bin/env bash

VOLUME=$(amixer sget Master | awk '/dB/ {print $4}' | tr -d '[]')

echo "♪ ${VOLUME}"
echo "♪ ${VOLUME}"
echo
