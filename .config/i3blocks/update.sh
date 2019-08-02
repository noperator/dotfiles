#!/usr/bin/env bash

grep signal "$HOME/.config/i3blocks/config" | sed 's/signal=//' | sort -n | while read SIG; do pkill --signal SIGRTMIN+"$SIG" i3blocks; done

