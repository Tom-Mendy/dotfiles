#!/bin/bash

if [ "$(command -v picom)" ]; then
  killall picom
  picom -b &
fi

if [ "$(command -v dunst)" ]; then
  killall dunst
  dunst &
fi

if [ "$(command -v nm-tray)" ]; then
  killall nm-tray
  nm-tray &
fi

if [ "$(command -v nm-applet)" ]; then
  killall nm-applet
  nm-applet &
fi

if [ "$(command -v blueman-applet)" ]; then
  killall blueman-applet
  blueman-applet &
fi

if [ "$(command -v pulseaudio)" ]; then
  killall pulseaudio
  pulseaudio --start &
fi

if [ "$(command -v volumeicon)" ]; then
  killall volumeicon
  volumeicon &
fi

if [ "$(command -v numlockx)" ]; then
  numlockx on &
fi

if [ "$(command -v parcellite)" ]; then
  killall parcellite
  parcellite &
fi

if [ "$(command -v xautolock)" ]; then
  killall xautolock
  xautolock -time 10 -locker "i3lock-fancy -p" &
fi

device_id=$(xinput | grep Touch | cut -f 2 | cut -d "=" -f 2)
tap_to_clic_id=$(xinput --list-props "$device_id" | grep "Tapping Enabled" -m 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
xinput set-prop "$device_id" "$tap_to_clic_id" 1
natural_scroll_id=$(xinput --list-props "$device_id" | grep "Natural Scrolling Enabled" -m 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
xinput set-prop "$device_id" "$natural_scroll_id" 1

#refresh wallpaper at startup
"$HOME/my_scripts/auto_wallpaper.sh" &
