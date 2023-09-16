#!/bin/bash
while :; do
    pgrep Xorg
    if [ $? -eq 0 ]; then
        break
    else
        sleep 1
    fi
done

sleep 1
xrandr -s 1920x1080
$HOME/my_scripts/auto_wallpaper.sh
