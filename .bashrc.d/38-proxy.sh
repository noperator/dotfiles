#!/bin/bash

ssp() { echo "[*] Starting background SSH SOCKS proxy on 127.0.0.1:$1 through host $2"; ssh -fND "127.0.0.1:$1" "$2"; }

case "$OSTYPE" in
    'darwin'*)
        burp() { /Applications/Burp\ Suite\ Professional.app/Contents/MacOS/JavaApplicationStub; }
        ;;
    'linux-gnu'*)
        # TO-DO
        ;;
esac
