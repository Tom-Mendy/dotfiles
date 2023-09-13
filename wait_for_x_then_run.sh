#!/bin/bash
while :; do
    xrandr -s 1920x1080
    if [ $? -eq 0 ]; then
        break
    else
        sleep 1
    fi
done

while :; do
    $HOME/my_scripts/auto_wallpaper.sh
    if [ $? -eq 0 ]; then
        break
    else
        sleep 1
    fi
done