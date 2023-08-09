#!/usr/bin/bash

echo "UPDATE"
sudo apt update
sudo apt upgrade -y

echo "INSTALL NALA"
sudo apt install nala -y

echo "-- INSTALL TIME --"
echo "XORG"
sudo nala install xorg xinit -y

echo "LOCK SCREEN"
sudo nala install lightdm -y

echo "WINDOW MANAGER"
sudo nala install i3 -y

echo "TERMINAL"
sudo nala install kitty -y

echo "BASE-APP"
sudo nala install vim tldr build-essential nm-tray network-manager pulseaudio pavucontrol bluez clipit -y

echo "Network MAnager"
sudo systemctl start NetworkManager.service 
sudo systemctl enable NetworkManager.service

echo "Docker Engine"
sudo nala update
sudo nala install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo nala update
sudo nala install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo groupadd docker
sudo usermod -aG docker $USER

echo "ZSH - OH MY ZSH"
cd /tmp
git clone https://github.com/JsuisSayker/zsh_auto_install.git
cd zsh_auto_install
./Debian.sh
cd ..
rm -r zsh_auto_install
cd

echo "Nix Package Manager"
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/tmendy/.nix-profile/etc/profile.d/nix.sh
mkdir -p ~/.config/nixpkgs/
echo "{ allowUnfree = true; }" >> ~/.config/nixpkgs/config.nix

echo "INSTALL Nix Package"

echo "Brave"
nix-env -iA nixpkgs.brave

echo "Discord"
nix-env -iA nixpkgs.discord

echo "Spotify"
nix-env -iA nixpkgs.spotify

echo "VSCode"
nix-env -iA nixpkgs.vscode

echo "NeoVim"
nix-env -iA nixpkgs.neovim

echo "Config NeoVim"
git clone https://github.com/Tom-Mendy/kickstart.nvim ~/.config/nvim
