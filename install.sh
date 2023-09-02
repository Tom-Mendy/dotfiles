#!/usr/bin/bash

function add_to_file_if_not_in_it {
  string="$1"
  path="$2"
  
  if ! grep -q "$string" "$path"; then
    echo "$string" >> "$path"
    echo "$string added to $path"
  else
    echo "$string already exists in $path"
  fi
}

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

echo "CLI-APP"
sudo nala install build-essential vim tldr exa bat ripgrep fzf fd-find neofetch htop -y

echo "C"
sudo nala install valgrind -y

echo "Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
chmod +x /tmp/rust.sh
/tmp/rust.sh -y
rm -f /tmp/rust.sh

echo "Nodejs"
sudo nala update
sudo nala install ca-certificates curl gnupg -y
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo nala update
sudo nala install nodejs -y

echo "Python-add"
sudo nala python3-pip python3-venv -y

echo "Lua"
sudo nala lua5.4 luarocks -y

echo "BASE-APP"
sudo nala install nm-tray network-manager pulseaudio pavucontrol bluez copyq thunar feh -y

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
sudo flatpak install flathub com.discordapp.Discord com.spotify.Client com.github.IsmaelMartinez.teams_for_linux -y

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
git clone https://github.com/neovim/neovim /tmp/neovim
cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
git checkout stable
sudo make install
cd
sudo rm -rf /tmp/neovim

echo "Config NeoVim"
sudo nala xclip -y
pip install neovim --break-system-packages
sudo npm install -g neovim tree-sitter-cli
git clone https://github.com/Tom-Mendy/kickstart.nvim ~/.config/nvim

echo "Ranger"
sudo nala install ranger -y

echo "Config Ranger"
mkdir ~/.config/ranger
touch ~/.config/ranger/rc.conf
# add icon plugin
mkdir ~/.config/ranger/plugins
git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
add_to_file_if_not_in_it 'default_linemode devicons' '~/.config/ranger/rc.conf'
add_to_file_if_not_in_it 'set show_hidden true' '~/.config/ranger/rc.conf'

echo "ZSH - OH MY ZSH"
git clone https://github.com/JsuisSayker/zsh_auto_install.git /tmp/zsh_auto_install
cd /tmp/zsh_auto_install
./Debian.sh
cd
sudo rm -rf /tmp/zsh_auto_install

echo "ADD line to .zshrc"
add_to_file_if_not_in_it 'alias Discord="com.discordapp.Discord"' '~/.zshrc'
add_to_file_if_not_in_it 'alias spotify="com.spotify.Client"' '~/.zshrc'
add_to_file_if_not_in_it 'alias teams-for-linux="com.github.IsmaelMartinez.teams_for_linux"' '~/.zshrc'
add_to_file_if_not_in_it 'alias cat="bat --paging=never"' '~/.zshrc'
add_to_file_if_not_in_it 'alias ls="exa --icons --color=always --group-directories-first"' '~/.zshrc'
add_to_file_if_not_in_it 'alias tree="exa --icons --color=always --group-directories-first --tree"' '~/.zshrc'

echo "Reboot Now"
