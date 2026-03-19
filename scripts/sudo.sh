#!/usr/bin/env bash
set -euo pipefail

# Install sudo and add current user to sudo group (Debian/Ubuntu style)
su -
apt update -y
apt install sudo git -y
sudo usermod -aG sudo "$USER"
echo "Reboot and launch install.sh"
sleep 2
sudo reboot
