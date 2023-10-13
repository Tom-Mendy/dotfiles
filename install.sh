#!/usr/bin/bash

# Enable exit on error
set -e

# Check if Script is Run as Root
if [[ $EUID -ne 1000 ]]; then
  echo "You must be a normal user to run this script, please run ./install.sh" 2>&1
  exit 1
fi

# Configuration
START=`date +%s`
USERNAME=$(id -u -n 1000)

if [[ "/home/$USERNAME" != "$HOME" ]]; then
  exit 1
fi

LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
mkdir -p $HOME/.config/
mkdir -p $HOME/my_scripts
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

# Log script start
log "Installation script started."

display "Sync Time"
sudo apt install -y ntp

display "UPDATE"
sudo apt update
sudo apt -y upgrade

display "Installing nala"
sudo apt install -y nala figlet curl

display "Refresh Mirrors"
yes |sudo nala fetch --auto
#add mirror refresh
add_to_file_if_not_in_it '@reboot yes |nala fetch --auto' "$CRONTAB_ROOT"

display "Start build-essential"
sudo nala install -y build-essential
display "End build-essential"

display "ZSH"
if [ ! "$(command -v zsh)" ]; then
  sudo nala install -y zsh fonts-font-awesome
  cp "$SCRIPT_DIR"/zsh/.zshrc $HOME/.zshrc
  mkdir $HOME/.zsh
  cp "$SCRIPT_DIR"/zsh/alias.zsh $HOME/.zsh
  cp "$SCRIPT_DIR"/zsh/env.zsh $HOME/.zsh
  cp "$SCRIPT_DIR"/zsh/.p10k.zsh $HOME/.p10k.zsh
fi

display "Start Flatpak"
sudo nala install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
display "End Flatpak"

display "Start Rust"
if [ ! "$(command -v cargo)" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
  chmod +x /tmp/rust.sh
  /tmp/rust.sh -y
  rm -f /tmp/rust.sh
  source $HOME/.cargo/env
fi
display "End Rust"

display "Start Nodejs"
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
display "End Nodejs"

display "Start Python-add"
sudo nala install -y python3-pip python3-venv
display "End Python-add"

display "Start Ruby"
sudo nala install -y ruby
display "End Ruby"

display "Go Start"
sudo nala install -y golang
display "Go End"

display "Java Start"
sudo nala install -y default-jdk
display "Java End"

display "Lua Start"
sudo nala install -y lua5.4 luarocks
display "Lua End"

display "C Start"
sudo nala install -y valgrind libcriterion-dev
display "C End"


display "Start Framwork & Header Updates"
sudo nala install -y linux-headers-$(uname -r) firmware-linux software-properties-common
display "End Framwork & Header Updates"

display "Start Network Management"
sudo nala install -y nm-tray network-manager
sudo systemctl start NetworkManager.service 
sudo systemctl enable NetworkManager.service
display "End Network Management"

display "Start Appearance and Customization"
sudo nala install -y lxappearance qt5ct arandr xclip parcellite
mkdir -p $HOME/.config/parcellite/
cp "$SCRIPT_DIR"/parcellite/* $HOME/.config/parcellite/
display "End Appearance and Customization"

display "Start System Utilities"
sudo nala install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
sudo systemctl enable avahi-daemon
sudo systemctl enable acpid
display "End System Utilities"

display "Start Terminal Emulators"
sudo nala install -y kitty
display "End Terminal Emulators"

display "Start Modern replacement"
cargo install eza fcp
sudo npm i -g safe-rm
sudo nala install -y tldr bat ripgrep fzf fd-find
display "End Modern replacement"

display "Start File Managers"
if [ ! "$(command -v xplr)" ]; then
  cargo install --locked --force xplr
  mkdir -p $HOME/.config/xplr
  xplr_version="$(xplr --version | awk '{print $2}')"
  echo "version = '${xplr_version:?}'" > $HOME/.config/xplr/init.lua
  cat "$SCRIPT_DIR"/xplr/init.lua >> $HOME/.config/xplr/init.lua
  # app for plugins
  # go install github.com/claudiodangelis/qrcp@latest
fi
sudo nala install -y thunar
display "End File Managers"

display "Start Audio Control Start"
sudo nala install -y pulseaudio alsa-utils pavucontrol volumeicon-alsa
display "End Audio Control End"

display "Start System Information and Monitoring"
sudo nala install -y neofetch htop
display "End System Information and Monitoring"

display "Start Screenshots"
sudo nala install -y flameshot
display "End Screenshots"

display "Start Printer Support"
sudo nala install -y cups simple-scan
sudo systemctl enable cups
display "End Printer Support"

display "Start Bluetooth Support"
sudo nala install -y bluez blueman
sudo systemctl enable bluetooth
display "End Bluetooth Support"

display "Start Menu and Window Managers"
sudo nala install -y numlockx rofi dunst libnotify-bin picom dmenu dbus-x11
display "Start Menu and Window Managers"

display "Start Communication"
sudo flatpak install -y flathub com.discordapp.Discord com.github.IsmaelMartinez.teams_for_linux
display "End Communication"

display "Start Text Editors"
sudo nala install -y vim
display "End Text Editors"

display "Start Image Viewer"
sudo nala install -y viewnior sxiv ueberzug python3-pillow
display "End Image Viewer"

display "Start Wallpaper"
sudo nala install -y feh
if [ ! "$(command -v wallrus)" ]; then
  if [ ! -d "/tmp/wallrus" ]; then
    git clone https://github.com/TheHamkerCat/wallrus /tmp/wallrus
  fi
  cd /tmp/wallrus
  bash ./install.sh
  cd -
  rm -rf /tmp/wallrus
fi
display "End Wallpaper"

display "Start Media Player"
sudo nala install -y vlc mpv
display "End Media Player"

display "Start Music Player"
sudo flatpak install -y flathub com.spotify.Client
display "End Music Player"

display "Start Document Viewer"
sudo nala install -y zathura
display "End Document Viewer"


display "Start X Window System and Input"
sudo apt -f install -y xorg xbacklight xinput xorg-dev xdotool brightnessctl
display "End X Window System and Input"

display "LOCK SCREEN Start"
sudo nala install -y libpam0g-dev libxcb-xkb-dev
if [ ! -d "/tmp/ly" ]; then
  git clone --recurse-submodules https://github.com/fairyglade/ly /tmp/ly
fi
cd /tmp/ly
make
sudo make install installsystemd
sudo systemctl enable ly.service
cd -
rm -rf /tmp/ly

# Configure xsessions
if [[ ! -d /usr/share/xsessions/i3.desktop ]]; then
  if [[ ! -d /usr/share/xsessions ]]; then
      sudo mkdir /usr/share/xsessions
  fi
cat > ./temp << "EOF"
[Desktop Entry]
Encoding=UTF-8
Name=i3
Comment=Manual Window Manager
Exec=i3
Icon=i3
Type=XSession
EOF
  sudo cp ./temp /usr/share/xsessions/i3.desktop;rm ./temp
fi
display "LOCK SCREEN End"

display "WINDOW MANAGER Start"
sudo nala install -y i3 i3lock-fancy xautolock
mkdir -p $HOME/.config/i3/
cp "$SCRIPT_DIR"/i3/* $HOME/.config/i3/
mkdir -p $HOME/.config/rofi/
cp "$SCRIPT_DIR"/rofi/* $HOME/.config/rofi/
display "WINDOW MANAGER End"

display "Theme Start"
# Desktop Theme
sudo nala install -y arc-theme
# Icons
if [ -z $(sudo find /usr/share/icons/ -iname "Flat-Remix-*") ]; then
  if [ ! -d "/tmp/flat-remix" ]; then
    git clone https://github.com/daniruiz/flat-remix.git /tmp/flat-remix
  fi
  sudo mv /tmp/flat-remix/Flat-Remix-* /usr/share/icons/
  rm -rf /tmp/flat-remix
fi
# Cursor
cd "$SCRIPT_DIR"
tar -xvf oreo-spark-purple-cursors.tar.gz
sudo mv oreo_spark_purple_cursors /usr/share/icons
cd -
# Add config
mkdir -p $HOME/.config/gtk-3.0/
cp $SCRIPT_DIR/gtk-3.0/.gtkrc-2.0 $HOME/
display "Theme End"

display "Bing Wallpaper Start"
if [ ! -f "$HOME/my_scripts/auto_wallpaper.sh" ]; then
  sudo nala install -y feh
  if [ ! -d "/tmp/auto_set_bing_wallpaper" ]; then
    git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git /tmp/auto_set_bing_wallpaper
  fi
  cp /tmp/auto_set_bing_wallpaper/auto_wallpaper.sh $HOME/my_scripts
fi
display "Bing Wallpaper End"

display "Docker Engine Start"
if [ ! "$(command -v docker)" ]; then
  sudo nala update
  sudo nala update
  sudo nala install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
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

display "Start Kubectl"
if [ ! "$(command -v kubectl)" ]; then
  sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  # add kubectl completion for zsh
  mkdir -p $HOME/.zsh/
  kubectl completion zsh > /tmp/kubectl.zsh
  tail -n +20 /tmp/kubectl.zsh > $HOME/.zsh/kubectl.zsh
  rm /tmp/kubectl.zsh
fi
display "End Kubectl"

display "Start Minikube"
if [ ! "$(command -v minikube)" ]; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
fi
display "End Minikube"

display "Brave Start"
if ! command -v brave-browser &> /dev/null; then
  sudo nala install -y curl
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"| sudo tee /etc/apt/sources.list.d/brave-browser-release.list
  sudo nala update
  sudo nala install -y brave-browser
fi
display "Brave End"

display "VSCodium Start"
if [ ! "$(command -v codium)" ]; then
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
  echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
  sudo nala update && sudo nala install -y codium
fi
display "VSCodium End"

display "Neovim Start"
if [ ! "$(command -v nvim)" ]; then
  sudo nala install -y ninja-build gettext cmake unzip curl
  if [ ! -d "/tmp/neovim" ]; then
    git clone https://github.com/neovim/neovim /tmp/neovim
  fi
  cd /tmp/neovim
  sudo make CMAKE_BUILD_TYPE=RelWithDebInfo
  git checkout stable
  sudo make install
  cd -
  # need sudo right beacause do "sudo make install"
  sudo rm -rf /tmp/neovim
fi
display "Neovim End"

display "Config NeoVim Start"
if [ ! -d "$HOME/.config/nvim" ]; then
  pip install neovim --break-system-packages
  if [ ! "$(command -v tree-sitter)" ]; then
    sudo npm install -g neovim tree-sitter-cli
  fi
  sudo nala install -y xclip
  git clone https://github.com/Tom-Mendy/nvim.git $HOME/.config/nvim
  # make .$HOME/.config/nvim work great for root
  sudo cp -r $HOME/.config/nvim /root/.config/nvim
fi
display "Config NeoVim End"

display "CRONTAB"
sudo crontab "$CRONTAB_ROOT"

sudo chown -R $USER:$USER /home/$USER

END=`date +%s`

RUNTIME=$((END-START))

display "Scrip executed in $RUNTIME s"

display "Type Your Password to make zsh your Default shell"
chsh -s /bin/zsh

display "Reboot Now"

# Log script completion
log "Installation script completed."
