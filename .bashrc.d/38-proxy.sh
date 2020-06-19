#!/bin/bash

ssp() { ssh -fND "$1" "$2"; }

case "$OSTYPE" in
    'darwin'*)
        alias burp='/Applications/Burp\ Suite\ Professional.app/Contents/MacOS/JavaApplicationStub &'
        gco() { /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --proxy-server="$1" "$2" & }
        ;;
    'linux-gnu'*)
        # TO-DO
        ;;
esac
