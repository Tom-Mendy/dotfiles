#!/usr/bin/bash

me=${USER}
su -
usermod -aG sudo ${me}
exit
echo "reboot and launch step2.sh"
