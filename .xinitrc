xrdb -load $HOME/.Xresources
xmodmap -e 'clear Lock'
xmodmap -e 'keycode 66=Escape'
xmodmap -e 'keycode 108=Multi_key'  # https://en.wikipedia.org/wiki/Compose_key#Common_compose_combinations
# exec i3
exec i3 --shmlog-size=26214400
