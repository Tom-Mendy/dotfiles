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
pulseaudio --start &

numlockx on &

killall parcellite
parcellite &

killall xautolock
xautolock -time 10 -locker "i3lock-fancy -p" &

device_id=$(xinput |grep Touch |cut -f 2 |cut -d "=" -f 2)
tap_to_clic_id=$(xinput --list-props $device_id |grep "Tapping Enabled" -m 1 |cut -d "(" -f 2 |cut -d ")" -f 1)
xinput set-prop $device_id $tap_to_clic_id 1
natural_scroll_id=$(xinput --list-props $device_id |grep "Natural Scrolling Enabled" -m 1 |cut -d "(" -f 2 |cut -d ")" -f 1)
xinput set-prop $device_id $natural_scroll_id 1

#refresh wallpaper at startup
$HOME/my_scripts/auto_wallpaper.sh &