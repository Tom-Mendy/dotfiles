#!/bin/sh

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
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

# take the distrubution info
. /etc/os-release
case $ID in
  arch)
    sudo pacman -Syu --noconfirm zsh ttf-font-awesome
    ;;
  debian)
    sudo apt install -y zsh fonts-font-awesome
    ;;
  fedora)
    sudo dnf install -y zsh fontawesome-fonts
    ;;
  *)
    echo "Unsupported OS"
    ;;
esac

# copy config
cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
mkdir -p "$HOME/.zsh"
cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

# make zsh the default shell
chsh -s /bin/zsh
