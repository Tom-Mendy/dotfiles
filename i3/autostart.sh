#!/bin/bash

picom -b &
dunst &

killall nm-tray
nm-tray &

killall blueman-tray
blueman-tray &

killall volumeicon
volumeicon &

numlockx on &

ibus-daemon -drx &

killall parcellite
parcellite &

killall xautolock
xautolock -time 10 -locker "i3lock-fancy -p" &

#refresh wallpaper at startup
xrandr -s 1920x1080 &
$HOME/my_scripts/auto_wallpaper.sh &