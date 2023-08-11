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
mkdir -p ~/.config/i3/
cp i3/config ~/.config/i3/
sudo cp i3/i3status.conf /etc/
sudo cp 99x11-common_start /etc/X11/Xsession.d/

echo "TERMINAL"
sudo nala install kitty -y

echo "BASE-APP"
sudo nala install vim tldr build-essential nm-tray network-manager pulseaudio pavucontrol bluez copyq neofetch htop thunar feh -y

echo "bing wallpaper just put code no exec"
mkdir -p ~/my_scripts
git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git ~/my_scripts

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

echo "Nix Package Manager"
sh <(curl -L https://nixos.org/nix/install) --no-daemon
#sleep to make sure there will be not bug and can install package
sleep 1
. /home/tmendy/.nix-profile/etc/profile.d/nix.sh
mkdir -p ~/.config/nixpkgs/  
echo "{ allowUnfree = true; }" >> ~/.config/nixpkgs/config.nix

echo "Flatpak"
sudo nala install flatpak -y
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
echo "INSTALL Flatpak Package"
sudo flatpak install flathub com.brave.Browser com.discordapp.Discord com.spotify.Client com.visualstudio.code -y

echo "Neovim"
sudo nala install ninja-build gettext cmake unzip curl -y
cd /tmp
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
sudo make install
cd ..
sudo rm -r neovim
cd

echo "Config NeoVim"
git clone https://github.com/Tom-Mendy/kickstart.nvim ~/.config/nvim

echo "ZSH - OH MY ZSH"
cd /tmp
git clone https://github.com/JsuisSayker/zsh_auto_install.git
cd zsh_auto_install
./Debian.sh
cd ..
sudo rm -r zsh_auto_install
cd

echo "ADD line to .zshrc"
echo 'alias brave="flatpak run com.brave.Browser"' >> ~/.zshrc
echo 'alias Discord="flatpak run com.discordapp.Discord"' >> ~/.zshrc
echo 'alias spotify="flatpak run com.spotify.Client"' >> ~/.zshrc
echo 'alias code="flatpak run com.visualstudio.code"' >> ~/.zshrc

echo "Reboot Now"
