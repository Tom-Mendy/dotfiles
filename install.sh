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

echo "i3 - Config"
cp i3status.conf /etc/i3status.conf
cp config ~/.config/i3/config
cp auto-start.sh /etc/X11/xinit/xinitrc.d/auto-start.sh

echo "TERMINAL"
sudo nala install kitty -y

echo "BASE-APP"
sudo nala install vim tldr build-essential nm-tray network-manager pulseaudio pavucontrol bluez diodon neofetch htop thunar nitrogen -y

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

echo "Nix Package Manager"
sh <(curl -L https://nixos.org/nix/install) --no-daemon


echo "INSTALL Flatpak Package"
sudo flatpak install flathub com.brave.Browser com.discordapp.Discord com.spotify.Client com.visualstudio.code io.neovim.nvim -y

echo "Config NeoVim"
git clone https://github.com/Tom-Mendy/kickstart.nvim ~/.var/app/io.neovim.nvim/config/nvim

echo "ZSH - OH MY ZSH"
cd /tmp
git clone https://github.com/JsuisSayker/zsh_auto_install.git
cd zsh_auto_install
./Debian.sh
cd ..
sudo rm -r zsh_auto_install
cd

echo "ADD line to .zshrc"
echo 'export PATH=~/my_scripts:$PATH' >> ~/.zshrc
echo 'export PATH=/var/lib/flatpak/exports/bin:$PATH' >> ~/.zshrc
echo 'export EDITOR="io.neovim.nvim"' >> ~/.zshrc
echo 'alias brave="com.brave.Browser"' >> ~/.zshrc
echo 'alias Discord="com.discordapp.Discord"' >> ~/.zshrc
echo 'alias spotify="com.spotify.Client"' >> ~/.zshrc
echo 'alias code="com.visualstudio.code"' >> ~/.zshrc
echo 'alias nvim="io.neovim.nvim"' >> ~/.zshrc

echo "Reboot Now"
