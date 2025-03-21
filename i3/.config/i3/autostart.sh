#!/usr/bin/env bash

# System Sound
if [ "$(command -v pulseaudio)" ]; then
  pulseaudio --start
fi

if [ "$(command -v pipewire)" ]; then
  pulseaudio --start
fi

## transparency
if [ "$(command -v picom)" ]; then
  killall picom
  picom --vsync -b
fi

#refresh wallpaper at startup
"$HOME/auto_wallpaper.sh" &

# notification
if [ "$(command -v dunst)" ]; then
  killall dunst
  dunst &
fi

## Network
# debian
if [ "$(command -v nm-tray)" ]; then
  killall nm-tray
  nm-tray &
fi
# fedora & arch & nixos
if [ "$(command -v nm-applet)" ]; then
  killall nm-applet
  nm-applet &
fi

## Bluetooth
if [ "$(command -v blueman-applet)" ]; then
  killall blueman-applet
  blueman-applet &
fi

# Sound applet
if [ "$(command -v volumeicon)" ]; then
  killall volumeicon
  volumeicon &
fi

## auto enable ver num
if [ "$(command -v numlockx)" ]; then
  numlockx on &
fi

## clipbord manager
if [ "$(command -v parcellite)" ]; then
  killall parcellite
  parcellite &
fi

## keyring
if [ "$(command -v gnome-keyring-daemon)" ]; then
  gnome-keyring-daemon -s
fi

#if [ "$(command -v xautolock)" ]; then
#  killall xautolock
#  xautolock -time 10 -locker "i3lock-fancy -p" &
#fi

# enable tap to click & natural scroll for my touch pad
device_id=$(xinput | grep Touch | cut -f 2 | cut -d "=" -f 2)
tap_to_clic_id=$(xinput --list-props "$device_id" | grep "Tapping Enabled" -m 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
xinput set-prop "$device_id" "$tap_to_clic_id" 1
natural_scroll_id=$(xinput --list-props "$device_id" | grep "Natural Scrolling Enabled" -m 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
xinput set-prop "$device_id" "$natural_scroll_id" 1
