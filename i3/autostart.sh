#!/bin/bash

picom -b &
dunst &

killall nm-tray
nm-tray &

killall blueman-applet
blueman-applet &

killall volumeicon
volumeicon &

numlockx on &

killall sxhkd
sxhkd -c ~/.config/sxhkd/sxhkdrc &

ibus-daemon -drx &

killall copyq
copyq &

#refresh wallpaper at startup
xrandr -s 1920x1080 &
$HOME/my_scripts/auto_wallpaper.sh &