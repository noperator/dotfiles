#!/bin/bash

grep signal "$(dirname $0)/config" |
sed 's/signal=//' |
sort -n |
while read SIG; do
    pkill --signal SIGRTMIN+"$SIG" i3blocks
done
