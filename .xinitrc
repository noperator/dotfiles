xrdb -load $HOME/.Xresources
xmodmap -e 'clear Lock'
xmodmap -e 'keycode 66=Escape'
xmodmap -e 'keycode 108=Multi_key'  # https://en.wikipedia.org/wiki/Compose_key#Common_compose_combinations

# Apparently I'm not supposed to use dbus-launch, but without it, notifications
# don't work properly on Debian 10.
# https://www.reddit.com/r/archlinux/comments/9uxbft/dbus_with_x11_support/e97wm6a?utm_source=share&utm_medium=web2x&context=3
exec dbus-launch --exit-with-session i3
