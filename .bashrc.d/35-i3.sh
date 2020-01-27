#!/bin/bash

# Refresh i3blocks. Note: External IP > VPN > Internal IP > Interface.

if [[ "$OSTYPE" == 'linux-gnu'* ]]; then
    ri3b() { pkill --signal SIGRTMIN+$@ i3blocks; }
    alias ri3b_cryfs='ri3b 1'
    alias ri3b_bt='ri3b 2'
    alias ri3b_extip='ri3b 6'
    alias ri3b_openvpn='ri3b 3; ri3b_extip'
    alias ri3b_intip='ri3b 5; ri3b_openvpn'
    alias ri3b_wifi='ri3b 4; ri3b_intip'
    alias ri3b_eth='ri3b 7; ri3b_intip'
    alias ei3='i3-msg exit'
fi
