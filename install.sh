#!/usr/bin/bash

# Configuration
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_USER="$SCRIPT_DIR/crontab/user"
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
mkdir -p "$HOME"/.config/
sudo mkdir -p /root/.config/

# Function to log messages
log() {
    local message="$1"
    sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

confirm() {
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

# Function to add a line to a file if it doesn't exist
add_to_file_if_not_in_it() {
    local string="$1"
    local path="$2"
  
    if ! grep -q "$string" "$path" &>/dev/null; then
        echo "$string" >> "$path" 
        echo "$string added to $path" 
    else
        echo "$string already exists in $path" 
    fi
}

# Function for displaying headers
display() {
    local header_text="$1"
    local DISPLAY_COMMAND="echo"
    
    if [ "$(command -v figlet)" ]; then
        DISPLAY_COMMAND="figlet"
    fi

    echo "--------------------------------------"
    $DISPLAY_COMMAND "$header_text"
    log "$header_text"
    echo "--------------------------------------"
}

# Enable exit on error
set -e

# Log script start
log "Installation script started."

display "Sync Time"
sudo apt install -y ntp

display "UPDATE"
sudo apt update
sudo apt -y upgrade

display "INSTALL NALA"
sudo apt install -y nala figlet curl

display "REFRESH MIRRORS"
yes |sudo nala fetch --auto
#add mirror refresh
add_to_file_if_not_in_it '@reboot yes |sudo nala fetch --auto' "$CRONTAB_USER"

display "XORG Start"
sudo apt -f install -y xorg xinit
display "XORG End"

display "LOCK SCREEN Start"
if ! dpkg -s lightdm >/dev/null 2>&1; then
  sudo nala install -y lightdm
  # enable list user on login screen
  sudo sed -i '109s/^.//' /etc/lightdm/lightdm.conf
  # copy user wallpaper to /usr/share/wallpapers/ as root
  add_to_file_if_not_in_it "@reboot cp $HOME/.bing_wallpaper.jpg /usr/share/wallpapers/" "$CRONTAB_ROOT"
  sudo sh -c "echo 'background=/usr/share/wallpapers/.bing_wallpaper.jpg' >> /etc/lightdm/lightdm-gtk-greeter.conf"
fi
display "LOCK SCREEN End"

display "WINDOW MANAGER Start"
sudo nala install -y i3 i3lock-fancy xbacklight
display "WINDOW MANAGER End"

display "i3 - Config Start"
sudo mkdir -p "$HOME"/.config/i3/
sudo cp "$SCRIPT_DIR"/i3/config "$HOME"/.config/i3/
sudo cp "$SCRIPT_DIR"/i3/i3status.conf /etc/
display "i3 - Config End"

display "TERMINAL Start"
sudo nala install -y kitty
display "TERMINAL End"

display "CLI-APP Start"
sudo nala install -y build-essential
sudo nala install -y vim tldr exa bat ripgrep fzf fd-find neofetch htop trash-cli
display "CLI-APP End"

display "C Start"
sudo nala install -y valgrind
display "C End"

display "Rust Start"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
chmod +x /tmp/rust.sh
/tmp/rust.sh -y
rm -f /tmp/rust.sh
display "Rust End"

display "Nodejs Start"
if [ ! "$(command -v npm)" ]; then
  sudo nala update
  sudo nala install -y ca-certificates curl gnupg
  sudo mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  sudo nala update
  sudo nala install -y nodejs
fi
display "Nodejs End"

display "Python-add Start"
sudo nala install -y python3-pip python3-venv
display "Python-add End"

display "Lua Start"
sudo nala install -y lua5.4 luarocks
display "Lua End"

display "BASE-APP Start"
sudo nala install -y nm-tray network-manager pulseaudio pavucontrol bluez copyq thunar feh
sudo systemctl start NetworkManager.service 
sudo systemctl enable NetworkManager.service
display "BASE-APP End"

display "Bing Wallpaper Start"
mkdir -p "$HOME"/my_scripts
sudo nala install -y feh
if [ ! -d "/tmp/auto_set_bing_wallpaper" ]; then
  git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git /tmp/auto_set_bing_wallpaper
fi
cp /tmp/auto_set_bing_wallpaper/auto_wallpaper.sh "$HOME"/my_scripts

display "Bing Wallpaper End"

display "Docker Engine Start"
if [ ! "$(command -v docker)" ]; then
  sudo nala update
  sudo nala install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo nala update
  sudo nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if ! getent group docker >/dev/null; then
    echo "Creating group: docker"
    sudo groupadd docker
  fi
  sudo usermod -aG docker "$USER"
fi
display "Docker Engine End"

display "Flatpak Start"
sudo nala install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

display "INSTALL Flatpak Package"
sudo flatpak install -y flathub com.discordapp.Discord com.spotify.Client com.github.IsmaelMartinez.teams_for_linux
display "Flatpak End"

display "Brave Start"
if ! command -v brave-browser &> /dev/null; then
  sudo nala install -y curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo nala update
  sudo nala install -y brave-browser
fi
display "Brave End"

display "VSCode Start"
if [ ! "$(command -v code)" ]; then
  sudo nala install -y wget gpg
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo nala install -y apt-transport-https
  sudo nala update
  sudo nala install -y code
fi
display "VSCode End"

display "Neovim Start"
if [ ! "$(command -v nvim)" ]; then
  sudo nala install -y ninja-build gettext cmake unzip curl
  if [ ! -d "/tmp/neovim" ]; then
    git clone https://github.com/neovim/neovim /tmp/neovim
  fi
  cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
  git checkout stable
  sudo make install
  cd
  sudo rm -rf /tmp/neovim
fi
display "Neovim End"

display "Config NeoVim Start"
pip install neovim --break-system-packages
if [ ! "$(command -v tree-sitter)" ]; then
  sudo npm install -g neovim tree-sitter-cli
fi
sudo nala install -y xclip
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/Tom-Mendy/kickstart.nvim "$HOME"/.config/nvim
fi
# make .$HOME/.config/nvim work great for root
sudo cp -r "$HOME"/.config/nvim /root/.config/nvim
display "Config NeoVim End"

display "Ranger Start"
sudo nala install -y ranger
display "Ranger End"

display "Config Ranger"
mkdir -p "$HOME"/.config/ranger/plugins
ranger --copy-config=all
# add icon plugin
if [ ! -d "$HOME/.config/ranger/plugins/ranger_devicons" ]; then
  git clone https://github.com/alexanderjeurissen/ranger_devicons "$HOME"/.config/ranger/plugins/ranger_devicons
fi
add_to_file_if_not_in_it 'default_linemode devicons' "$HOME/.config/ranger/rc.conf"
add_to_file_if_not_in_it 'set show_hidden true' "$HOME/.config/ranger/rc.conf"
# make .$HOME/.config/nvim work great for root
sudo cp -r "$HOME"/.config/ranger /root/.config/ranger
display "Ranger End"

display "ZSH"
sudo nala install -y zsh fonts-font-awesome
chsh -s /bin/zsh
cp "$SCRIPT_DIR"/zsh/.zshrc "$HOME"/.zshrc
mkdir "$HOME"/.zsh
cp "$SCRIPT_DIR"/zsh/alias.zsh "$HOME"/.zsh
cp "$SCRIPT_DIR"/zsh/env.zsh "$HOME"/.zsh
cp "$SCRIPT_DIR"/zsh/.p10k.zsh "$HOME"/.p10k.zsh

display "CRONTAB"
crontab "$CRONTAB_USER"
sudo crontab "$CRONTAB_ROOT"

display "Reboot Now"

# Log script completion
log "Installation script completed."