#!/usr/bin/env bash

# Documentation
# https://www.gnu.org/software/stow/manual/stow.html

# Check if Script is Run as Root
if [[ $EUID -ne 1000 ]]; then
  echo "You must be a normal user to run this script, please run ./install_zsh.sh" 2>&1
  exit 1
fi

USERNAME=$(id -u -n 1000)

if [[ "/home/$USERNAME" != "$HOME" ]]; then
  exit 1
fi

# Configuration
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [ ! "$(command -v stow)" ]; then
  echo "Installing stow"
  # take the distrubution info
  . /etc/os-release
  case $ID in
  arch)
    sudo pacman -Syu --noconfirm stow
    ;;
  debian | ubuntu)
    sudo apt install -y stow
    ;;
  fedora)
    sudo dnf install -y stow
    ;;
  nixos)
    nix-env -iA nixos.stow
    ;;
  *)
    echo "Unsupported OS"
    echo "command \"stow\" don't exists on system"
    ;;
  esac
fi

stow -t $HOME -d $SCRIPT_DIR -v -R -S hypr vim nvim i3 nushell bash kitty tmux zsh wofi rofi waybar

echo "Dotfiles installed successfully"
