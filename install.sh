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
sudo nala install vim tldr build-essential nm-tray network-manager pulseaudio pavucontrol bluez clipit neofetch htop thunar nitrogen -y

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

echo "i3 - Config"
cd /tmp
git clone https://github.com/Tom-Mendy/i3-config.git
cd i3-config
./install.sh
cd ..
sudo rm -r i3-config
cd

echo "ZSH - OH MY ZSH"
cd /tmp
git clone https://github.com/JsuisSayker/zsh_auto_install.git
cd zsh_auto_install
./Debian.sh
cd ..
sudo rm -r zsh_auto_install
cd

echo "ADD line to .zshrc"
echo "export PATH=~/my_scripts:$PATH" >> ~/.zshrc
echo "export EDITOR=flatpak run io.neovim.nvim" >> ~/.zshrc
echo 'alias brave="flatpak run com.brave.Browser"' >> ~/.zshrc
echo 'alias Discord="flatpak run com.discordapp.Discord"' >> ~/.zshrc
echo 'alias spotify="flatpak run com.spotify.Client"' >> ~/.zshrc
echo 'alias code="flatpak run com.visualstudio.code"' >> ~/.zshrc
echo 'alias nvim="flatpak run io.neovim.nvim"' >> ~/.zshrc

echo "Flatpak"
sudo nala install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "INSTALL Flatpak Package"
flatpak install flathub com.brave.Browser -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub com.spotify.Client -y
flatpak install flathub com.visualstudio.code -y
flatpak install flathub io.neovim.nvim -y

echo "Config NeoVim"
git clone https://github.com/Tom-Mendy/kickstart.nvim ~/.config/nvim

echo "Reboot Now"
