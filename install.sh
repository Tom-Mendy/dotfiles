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
sudo chmod 644 /etc/X11/Xsession.d/99x11-common_start

echo "TERMINAL"
sudo nala install kitty -y

echo "BASE-APP"
sudo nala install vim tldr build-essential nm-tray network-manager pulseaudio pavucontrol bluez copyq neofetch htop thunar feh valgrind -y

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

echo "Flatpak"
sudo nala install flatpak -y
# update certificate
sudo apt install --reinstall ca-certificates
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "INSTALL Flatpak Package"
sudo flatpak install flathub com.discordapp.Discord com.spotify.Client -y

echo "Brave"
sudo nala install curl -y
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update
sudo nala install brave-browser -y

echo "VSCode"
sudo nala install wget gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo nala install apt-transport-https -y
sudo nala update
sudo nala install code -y

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
echo 'alias Discord="com.discordapp.Discord"' >> ~/.zshrc
echo 'alias spotify="com.spotify.Client"' >> ~/.zshrc

echo "Reboot Now"
