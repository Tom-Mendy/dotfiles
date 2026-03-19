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
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

if [ ! "$(command -v stow)" ]; then
  "$SCRIPT_DIR/install_stow.sh"
fi

stow -t "${HOME}" -d "${SCRIPT_DIR}" -v -R -S hypr vim nvim i3 nushell bash kitty tmux zsh wofi rofi waybar ghostty

# tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "Dotfiles installed successfully"
