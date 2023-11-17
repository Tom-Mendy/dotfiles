#!/bin/bash

distrobox create --name arch --image quay.io/toolbx-images/archlinux-toolbox:latest --yes --init
distrobox enter arch -- $SCRIPT_DIR/distrobox/arch.sh