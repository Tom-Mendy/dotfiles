#!/usr/bin/env bash
set -e
xset s off dpms 0 10 0
i3lock-fancy -p --nofork
xset s off -dpms
