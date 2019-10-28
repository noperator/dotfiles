#!/bin/bash

alias rx="xrdb $HOME/.Xresources"
alias rxp="xrandr --output eDP1 --pos 0x0"
alias xa="xrandr --auto"
alias xd1="xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --output HDMI2 --off; fb"
alias xd2="xrandr --output eDP1 --mode 1920x1080 --pos 0x0 --output HDMI2 --mode 1920x1080 --pos 1920x0; fb"  # external right
alias xb="xbacklight -set"
