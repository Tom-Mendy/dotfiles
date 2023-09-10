#!/usr/bin/bash

su -
apt install sudo git -y
sudo usermod -aG sudo $USER
echo "reboot and launch install.sh"
sleep 2
sudo reboot
