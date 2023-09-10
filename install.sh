#!/usr/bin/bash

function confirm {
    while true; do
        read -p "Do you want to proceed? [Yes/No/Cancel] " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            [Cc]* ) exit;;
            * ) echo "Please answer YES, NO, or CANCEL.";;
        esac
    done
}

# Example usage of the confirm function
# if confirm; then
#     echo "User chose YES. Executing the operation..."
#     # Place your code here to execute when user confirms
# else
#     echo "User chose NO. Aborting the operation..."
#     # Place your code here to execute when user denies
# fi

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

# the dir where the script is located
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# make .cofig work great as root
sudo mkdir -p $HOME/.config
sudo ln -s $HOME/.config /root/.config

echo "UPDATE"
sudo apt update
sudo apt -y upgrade

echo "INSTALL NALA"
sudo apt install -y nala
yes |sudo nala fetch --auto

echo "-- INSTALL TIME --"
echo "XORG"
sudo nala install -y xorg xinit

echo "LOCK SCREEN"
sudo nala install -y lightdm

echo "WINDOW MANAGER"
sudo nala install -y i3

echo "i3 - Config"
mkdir -p $HOME/.config/i3/
cp $SCRIPT_DIR/i3/config $HOME/.config/i3/
sudo cp $SCRIPT_DIR/i3/i3status.conf /etc/
sudo cp $SCRIPT_DIR/99x11-common_start /etc/X11/Xsession.d/
sudo chmod 644 /etc/X11/Xsession.d/99x11-common_start

echo "TERMINAL"
sudo nala install -y kitty

echo "CLI-APP"
sudo nala install -y build-essential
sudo nala install -y vim tldr exa bat ripgrep fzf fd-find neofetch htop

echo "C"
sudo nala install -y valgrind

echo "Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
chmod +x /tmp/rust.sh
/tmp/rust.sh -y
rm -f /tmp/rust.sh

echo "Nodejs"
sudo nala update
sudo nala install -y ca-certificates curl gnupg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=20
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
sudo nala update
sudo nala install -y nodejs

echo "Python-add"
sudo nala install -y python3-pip python3-venv

echo "Lua"
sudo nala install -y lua5.4 luarocks

echo "BASE-APP"
sudo nala install -y nm-tray network-manager pulseaudio pavucontrol bluez copyq thunar feh

echo "bing wallpaper just put code no exec"
mkdir -p $HOME/my_scripts
git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git /tmp/auto_set_bing_wallpaper
cp /tmp/auto_set_bing_wallpaper/auto_wallpaper.sh $HOME/my_scripts

echo "Network MAnager"
sudo systemctl start NetworkManager.service 
sudo systemctl enable NetworkManager.service

echo "Docker Engine"
sudo nala update
sudo nala install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo nala update
sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Flatpak"
sudo nala install -y flatpak
# update certificate
sudo apt install --reinstall ca-certificates
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "INSTALL Flatpak Package"
sudo flatpak install -y flathub com.discordapp.Discord com.spotify.Client com.github.IsmaelMartinez.teams_for_linux

echo "Brave"
sudo nala install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update
sudo nala install -y brave-browser

echo "VSCode"
sudo nala install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg
sudo nala install -y apt-transport-https
sudo nala update
sudo nala install -y code

echo "Neovim"
sudo nala install -y ninja-build gettext cmake unzip curl
git clone https://github.com/neovim/neovim /tmp/neovim
cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
git checkout stable
sudo make install
cd
sudo rm -rf /tmp/neovim

echo "Config NeoVim"
sudo nala -y xclip
pip install neovim --break-system-packages
sudo npm install -g neovim tree-sitter-cli
git clone https://github.com/Tom-Mendy/kickstart.nvim $HOME/.config/nvim

echo "Ranger"
sudo nala install -y ranger

echo "Config Ranger"
ranger --copy-config=all
# add icon plugin
mkdir $HOME/.config/ranger/plugins
git clone https://github.com/alexanderjeurissen/ranger_devicons $HOME/.config/ranger/plugins/ranger_devicons
add_to_file_if_not_in_it 'default_linemode devicons' "$HOME/.config/ranger/rc.conf"
add_to_file_if_not_in_it 'set show_hidden true' "$HOME/.config/ranger/rc.conf"

echo "ZSH - OH MY ZSH"
git clone https://github.com/JsuisSayker/zsh_auto_install.git /tmp/zsh_auto_install
cd /tmp/zsh_auto_install
./Debian.sh
cd
sudo rm -rf /tmp/zsh_auto_install
# make zsh work great as root
sudo ln -s $HOME/.zshrc /root/.zshrc
sudo ln -s $HOME/.zsh_history /root/.zsh_history
sudo ln -s $HOME/.p10k.zsh /root/.p10k.zsh
sudo ln -s $HOME/.oh-my-zsh /root/.oh-my-zsh

echo "ADD line to .zshrc"
add_to_file_if_not_in_it 'alias Discord="com.discordapp.Discord"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias spotify="com.spotify.Client"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias teams-for-linux="com.github.IsmaelMartinez.teams_for_linux"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias bat="batcat"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias cat="batcat --paging=never"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias ls="exa --icons --color=always --group-directories-first"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias la="exa --icons --color=always --group-directories-first -a"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias ll="exa --icons --color=always --group-directories-first -l"' "$HOME/.zshrc"
add_to_file_if_not_in_it 'alias tree="exa --icons --color=always --group-directories-first --tree"' "$HOME/.zshrc"

#add all .file to root 
sudo ln -s $HOME/.* /root/

echo "Reboot Now"
