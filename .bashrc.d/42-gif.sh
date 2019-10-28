#!/bin/bash

gif() {
    ffmpeg -i "$@" -r 10 -f image2pipe -vcodec ppm - |\
    convert -verbose +dither -layers Optimize -resize 700x700\> - gif:- |\
    gifsicle --colors 128 --delay=5 --loop --optimize=3 --multifile - > "${@}.gif"
}
