#!/usr/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi
# Configuration
START=`date +%s`
USERNAME=$(id -u -n 1000)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
mkdir -p /home/"$USERNAME"/.config/
mkdir -p /root/.config/

# Function to log messages
log() {
    local message="$1"
    sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
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
apt install -y ntp

display "UPDATE"
apt update
apt -y upgrade

display "Installing nala"
apt install -y nala figlet curl

display "Refresh Mirrors"
yes |nala fetch --auto
#add mirror refresh
add_to_file_if_not_in_it '@reboot yes |nala fetch --auto' "$CRONTAB_ROOT"

display "Start build-essential"
nala install -y build-essential
display "End build-essential"

display "Start X Window System and Input"
apt -f install -y xorg xbacklight xinput xorg-dev xdotool brightnessctl
display "End X Window System and Input"

display "Start Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
chmod +x /tmp/rust.sh
/tmp/rust.sh -y
rm -f /tmp/rust.sh
display "End Rust"

display "Start Nodejs"
if [ ! "$(command -v npm)" ]; then
  nala update
  nala install -y ca-certificates curl gnupg
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
  NODE_MAJOR=20
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
  nala update
  nala install -y nodejs
fi
display "End Nodejs"

display "Start Python-add"
nala install -y python3-pip python3-venv
display "End Python-add"

display "Start Framwork & Header Updates"
nala install -y linux-headers-$(uname -r) firmware-linux software-properties-common
display "End Framwork & Header Updates"

display "Start Network Management"
nala install -y nm-tray network-manager
systemctl start NetworkManager.service 
systemctl enable NetworkManager.service
display "End Network Management"

display "Start Appearance and Customization"
nala install -y lxappearance qt5ct arandr xclip copyq
display "End Appearance and Customization"

display "Start System Utilities"
nala install -y dialog mtools dosfstools avahi-daemon acpi acpid gvfs-backends
systemctl enable avahi-daemon
systemctl enable acpid
display "End System Utilities"

display "Start Terminal Emulators"
nala install -y kitty
display "End Terminal Emulators"

display "Start Modern replacement"
nala install -y exa tldr bat ripgrep fzf fd-find
display "End Modern replacement"

display "Start File Managers"
cargo install --locked --force xplr
nala install -y thunar
display "End File Managers"

display "Start Audio Control Start"
nala install -y pulseaudio alsa-utils pavucontrol volumeicon-alsa
display "End Audio Control End"

display "Start System Information and Monitoring"
nala install -y neofetch htop
display "End System Information and Monitoring"

display "Start Screenshots"
nala install -y flameshot
display "End Screenshots"

display "Start Printer Support"
nala install -y cups simple-scan
systemctl enable cups
display "End Printer Support"

display "Start Bluetooth Support"
nala install -y bluez blueman
systemctl enable bluetooth
display "End Bluetooth Support"

display "Start Menu and Window Managers"
nala install -y sxhkd numlockx rofi dunst libnotify-bin picom dmenu polybar dbus-x11
display "Start Menu and Window Managers"

display "Start Archive Management"
nala install -y unzip file-roller
display "End Archive Management"

display "Start Text Editors"
nala install -y vim mousepad
display "End Text Editors"

display "Start Image Viewer"
nala install -y viewnior feh sxiv ueberzug python3-pillow
display "End Image Viewer"

display "Start Media Player"
nala install -y vlc
display "End Media Player"

display "Start Document Viewer"
nala install -y zathura
display "End Document Viewer"

display "C Start"
nala install -y valgrind
display "C End"

display "Lua Start"
nala install -y lua5.4 luarocks
display "Lua End"

display "LOCK SCREEN Start"
nala install -y build-essential libpam0g-dev libxcb-xkb-dev
git clone --recurse-submodules https://github.com/fairyglade/ly /tmp/ly
cd /tmp/ly
make
make install installsystemd
systemctl enable ly.service
cd -
rm -rf /tmp/ly

# Configure xsessions
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

display "LOCK SCREEN End"

display "WINDOW MANAGER Start"
nala install -y i3 i3lock-fancy
display "WINDOW MANAGER End"

display "i3 - Config Start"
mkdir -p /home/"$USERNAME"/.config/i3/
cp "$SCRIPT_DIR"/i3/config /home/"$USERNAME"/.config/i3/
cp "$SCRIPT_DIR"/i3/i3status.conf /etc/
display "i3 - Config End"

display "Bing Wallpaper Start"
mkdir -p /home/"$USERNAME"/my_scripts
nala install -y feh
if [ ! -d "/tmp/auto_set_bing_wallpaper" ]; then
  git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git /tmp/auto_set_bing_wallpaper
fi
cp /tmp/auto_set_bing_wallpaper/auto_wallpaper.sh /home/"$USERNAME"/my_scripts

display "Bing Wallpaper End"

display "Docker Engine Start"
if [ ! "$(command -v docker)" ]; then
  nala update
  nala install -y ca-certificates curl gnupg
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  nala update
  nala install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if ! getent group docker >/dev/null; then
    echo "Creating group: docker"
    groupadd docker
  fi
  usermod -aG docker "$USERNAME"
fi
display "Docker Engine End"

display "Flatpak Start"
nala install -y flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

display "INSTALL Flatpak Package"
flatpak install -y flathub com.discordapp.Discord com.spotify.Client com.github.IsmaelMartinez.teams_for_linux
display "Flatpak End"

display "Brave Start"
if ! command -v brave-browser &> /dev/null; then
  nala install -y curl
  curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main"|tee /etc/apt/sources.list.d/brave-browser-release.list
  nala update
  nala install -y brave-browser
fi
display "Brave End"

display "VSCodium Start"
if [ ! "$(command -v codium)" ]; then
  wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
  echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | tee /etc/apt/sources.list.d/vscodium.list
  nala update && nala install -y codium
fi
display "VSCodium End"

display "Neovim Start"
if [ ! "$(command -v nvim)" ]; then
  nala install -y ninja-build gettext cmake unzip curl
  if [ ! -d "/tmp/neovim" ]; then
    git clone https://github.com/neovim/neovim /tmp/neovim
  fi
  cd /tmp/neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo
  git checkout stable
  make install
  cd
  rm -rf /tmp/neovim
fi
display "Neovim End"

display "Config NeoVim Start"
pip install neovim --break-system-packages
if [ ! "$(command -v tree-sitter)" ]; then
  npm install -g neovim tree-sitter-cli
fi
nala install -y xclip
if [ ! -d "/home/$USERNAME/.config/nvim" ]; then
  git clone https://github.com/Tom-Mendy/kickstart.nvim /home/"$USERNAME"/.config/nvim
fi
# make .$HOME/.config/nvim work great for root
cp -r /home/"$USERNAME"/.config/nvim /root/.config/nvim
display "Config NeoVim End"

display "Ranger Start"
nala install -y ranger
display "Ranger End"

display "Config Ranger"
mkdir -p /home/"$USERNAME"/.config/ranger/plugins
ranger --copy-config=all
# add icon plugin
if [ ! -d "$HOME/.config/ranger/plugins/ranger_devicons" ]; then
  git clone https://github.com/alexanderjeurissen/ranger_devicons /home/"$USERNAME"/.config/ranger/plugins/ranger_devicons
fi
add_to_file_if_not_in_it 'default_linemode devicons' "$HOME/.config/ranger/rc.conf"
add_to_file_if_not_in_it 'set show_hidden true' "$HOME/.config/ranger/rc.conf"
# make .$HOME/.config/nvim work great for root
cp -r /home/"$USERNAME"/.config/ranger /root/.config/ranger
display "Ranger End"

display "ZSH"
if [ ! "$(command -v zsh)" ]; then
  nala install -y zsh fonts-font-awesome
  chsh -s /bin/zsh
  cp "$SCRIPT_DIR"/zsh/.zshrc /home/"$USERNAME"/.zshrc
  mkdir /home/"$USERNAME"/.zsh
  cp "$SCRIPT_DIR"/zsh/alias.zsh /home/"$USERNAME"/.zsh
  cp "$SCRIPT_DIR"/zsh/env.zsh /home/"$USERNAME"/.zsh
  cp "$SCRIPT_DIR"/zsh/.p10k.zsh /home/"$USERNAME"/.p10k.zsh
fi

display "CRONTAB"
crontab "$CRONTAB_ROOT"

chown -R $USERNAME:$USERNAME /home/$USERNAME

END=`date +%s`

RUNTIME=$((END-START))

display "Scrip executed in $RUNTIME s"

display "Run $> chsh -s /bin/zsh"

display "Reboot Now"

# Log script completion
log "Installation script completed."