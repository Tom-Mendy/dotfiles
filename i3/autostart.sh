#!/bin/bash

killall picom
picom -b &

killall dunst
dunst &

killall nm-tray
nm-tray &

killall blueman-applet
blueman-applet &

killall pulseaudio
pulseaudio --start

killall volumeicon
volumeicon &

numlockx on &

killall parcellite
parcellite -d &

killall xautolock
xautolock -time 10 -locker "i3lock-fancy -p" &

xinput
device_id=$(xinput | grep Touch | cut -f 2 | cut -d "=" -f 2)
echo "$device_id"
xinput set-prop $device_id 317 1
xinput set-prop $device_id 294 1

#refresh wallpaper at startup
$HOME/my_scripts/auto_wallpaper.sh &
