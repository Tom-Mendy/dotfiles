#!/bin/bash

# install kitty for compatibility
sudo pacman -Syyu --noconfirm kitty

# install paru for AUR
sudo pacman -S --noconfirm --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
