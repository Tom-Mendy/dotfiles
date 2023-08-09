#!/usr/bin/bash

su -
apt update && apt upgrade
apt install sudo git -y
usermod -aG sudo $1
exit
echo "reboot and launch step2.sh"
