#!/bin/bash

echo "all you camera"
ls /dev/video*

sudo dnf copr enable principis/howdy
sudo dnf --refresh install howdy

sudo mkdir /usr/lib64/security/howdy/snapshots
