#!/bin/bash

# Enable exit on error
set -e

# Function to log messages
log() {
  local message="$1"
  sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
}

confirm() {
  while true; do
    read -rp "Do you want to proceed? [Yes/No/Cancel] " yn
    case $yn in
    [Yy]*) return 0 ;;
    [Nn]*) return 1 ;;
    [Cc]*) exit ;;
    *) echo "Please answer YES, NO, or CANCEL." ;;
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
    echo "$string" >>"$path"
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

###START_PROGRAM###

# Check if Script is Run as Root
if [[ $EUID -ne 1000 ]]; then
  echo "You must be a normal user to run this script, please run ./install.sh" 2>&1
  exit 1
fi

USERNAME=$(id -u -n 1000)

if [[ "/home/$USERNAME" != "$HOME" ]]; then
  exit 1
fi

# Configuration
START=$(date +%s)
LOG_FILE="/var/log/installation.log"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
mkdir -p "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Music"
mkdir -p "$HOME/.config/"

# define what you want to install
INSTALL_MY_SCRIPT=true
INSTALL_RUBY=true
INSTALL_JAVA=true
INSTALL_GO=true
INSTALL_LUA=true
INSTALL_C=true
INSTALL_HASKELL=true
INSTALL_DOCKER=true
INSTALL_PODMAN=true
INSTALL_TUI_FILE_MANAGER=true
INSTALL_SPOTIFY=false
INSTALL_FIREFOX=true
INSTALL_CHROME=true
INSTALL_BRAVE=false
INSTALL_VSCODE=true
INSTALL_VSCODIUM=false
INSTALL_JETBRAINS=true
INSTALL_NVIM=true

# Log script start
log "Installation script started."

if [ $INSTALL_MY_SCRIPT == true ]; then
  # Update Submodule
  git submodule update --init --recursive
  # copy my scripts
  cp -r "$SCRIPT_DIR/my_scripts" "$HOME"
fi

display "UPDATE"
sudo pacman -Syyu --noconfirm

display "Installing Paru"
if [ ! "$(command -v paru)" ]; then
  sudo pacman -S --needed base-devel
  git clone https://aur.archlinux.org/paru.git /tmp/paru
  cd /tmp/paru
  makepkg -si --noconfirm
  cd -
fi

display "Start base-devel"
sudo paru -Syu --noconfirm base-devel xdg-user-dirs vim wget curl
log "End base-devel"

# Remove PC Speaker Beep
sudo rmmod pcspkr

display "ZSH"
if [ ! "$(command -v zsh)" ]; then
  sudo paru -Syu --noconfirm zsh ttf-font-awesome
  cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
  mkdir "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

display "Start Flatpak"
sudo paru -Syu --noconfirm flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "End Flatpak"

display "Start Rust"
sudo paru -Syu --noconfirm rust
log "End Rust"

display "Start Nodejs"
sudo paru -Syu --noconfirm npm nodejs
log "End Nodejs"

display "Start Python-add"
sudo paru -Syu --noconfirm python python-pip python-pipenv
log "End Python-add"

if [ $INSTALL_RUBY == true ]; then
  display "Start Ruby"
  sudo paru -Syu --noconfirm ruby
  log "End Ruby"
fi

if [ $INSTALL_JAVA == true ]; then
  display "Java Start"
  sudo paru -Syu --noconfirm jdk-openjdk
  log "Java End"
fi

if [ $INSTALL_GO == true ]; then
  display "Go Start"
  sudo paru -Syu --noconfirm go
  log "Go End"
fi

if [ $INSTALL_LUA == true ]; then
  display "Lua Start"
  sudo paru -Syu --noconfirm lua luarocks
  log "Lua End"
fi

if [ $INSTALL_C == true ]; then
  display "C Start"
  sudo paru -Syu --noconfirm cppcheck gdb valgrind lldb gcovr ncurses csfml
  "$SCRIPT_DIR/criterion/install_criterion.sh"
  log "C End"
fi

if [ $INSTALL_HASKELL == true ]; then
  display "HASKELL Start"
  sudo paru -Syu --noconfirm ghc
  log "HASKELL End"
fi

if [ $INSTALL_DOCKER == true ]; then
  display "Docker Engine Start"
  if [ ! "$(command -v docker)" ]; then
    sudo paru -Syu --noconfirm docker
    if ! getent group docker >/dev/null; then
      echo "Creating group: docker"
      sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"
    sudo systemctl enable containerd.service
    sudo systemctl enable docker.service
  fi
  log "Docker Engine End"
fi

if [ $INSTALL_PODMAN == true ]; then
  display "Podman Start"
  sudo paru -Syu --noconfirm podman
  log "Podman End"
fi

# display "Start Network Management"
# sudo paru -Syu --noconfirm network-manager-applet
# sudo systemctl start NetworkManager.service
# sudo systemctl enable NetworkManager.service
# log "End Network Management"

display "Start Clipboard"
sudo paru -Syu --noconfirm cliphist wl-clipboard
log "End Clipboard"

# display "Start System Utilities"
# sudo paru -Syu --noconfirm dialog mtools dosfstools avahi acpi acpid gvfs
# sudo systemctl enable acpid
# log "End System Utilities"

# display "Start Terminal Emulators"
# sudo paru -Syu --noconfirm kitty
# mkdir -p "$HOME/.config/kitty/"
# cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"
# log "End Terminal Emulators"

display "Start Modern replacement"
cargo install fcp
sudo npm i -g safe-rm
sudo paru -Syu --noconfirm eza tldr bat ripgrep fzf
log "End Modern replacement"

display "Start More icons"
if [ ! -d "/tmp/devicons" ]; then
  git clone https://github.com/vorillaz/devicons.git "/tmp/devicons"
  sudo cp /tmp/devicons/fonts/devicons.ttf /usr/share/fonts/
  fc-cache -f -v
fi
log "End More icons"

display "Start File Managers"
# terminal base
if [ $INSTALL_TUI_FILE_MANAGER == true ]; then
  if [ ! "$(command -v yazi)" ]; then
    cargo install --locked yazi-fm
  fi
fi
log "End File Managers"

display "Start System Information and Monitoring"
sudo paru -Syu --noconfirm neofetch htop btop
mkdir -p "$HOME/.config/neofetch/"
cp -r "$SCRIPT_DIR/neofetch/"* "$HOME/.config/neofetch/"
log "End System Information and Monitoring"

display "Start Screenshots"
sudo paru -Syu --noconfirm flameshot
log "End Screenshots"

# display "Start Printer Support"
# sudo paru -Syu --noconfirm cups simple-scan
# sudo systemctl enable cups
# log "End Printer Support"

display "Start Bluetooth Support"
sudo paru -Syu --noconfirm bluez bluez-utils blueman
sudo systemctl enable bluetooth
log "End Bluetooth Support"

display "Start Communication"
if [ ! "$(command -v com.discordapp.Discord)" ]; then
  sudo flatpak install -y flathub com.discordapp.Discord
fi
paru -Syu --noconfirm teams-for-linux
log "End Communication"

display "Start Text Editors"
sudo paru -Syu --noconfirm vim
cp "$SCRIPT_DIR/vim/.vimrc" "$HOME"
log "End Text Editors"

# display "Start Image Viewer"
# sudo paru -Syu --noconfirm viewnior sxiv ueberzug python-pillow
# log "End Image Viewer"

display "Start Media Player"
sudo paru -Syu --noconfirm vlc mpv
log "End Media Player"

display "Start Music Player"
if [ $INSTALL_SPOTIFY == true ]; then
  paru -Syu --noconfirm spotify
fi
log "End Music Player"

display "WINDOW MANAGER Start"
sudo paru -Syu --noconfirm waybar hyprpaper udiskie
mkdir -p "$HOME/.config/hypr/"
cp "$SCRIPT_DIR/hypr/"* "$HOME/.config/hypr/"
mkdir -p "$HOME/.config/waybar/"
cp "$SCRIPT_DIR/waybar/"* "$HOME/.config/waybar/"
mkdir -p "$HOME/.config/wofi/"
cp "$SCRIPT_DIR/wofi/"* "$HOME/.config/wofi/"
display "WINDOW MANAGER End"

display "Bing Wallpaper Start"
if [ ! -f "$HOME/my_scripts/auto_wallpaper.sh" ]; then
  sudo paru -Syu --noconfirm hyprpaper
  if [ ! -d "/tmp/auto_set_bing_wallpaper" ]; then
    git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git /tmp/auto_set_bing_wallpaper
  fi
  cp /tmp/auto_set_bing_wallpaper/auto_wallpaper.sh "$HOME/my_scripts"
fi
display "Bing Wallpaper End"

if [ $INSTALL_FIREFOX == true ]; then
  display "Start firefox"
  paru -Syu --noconfirm firefox
  log "End firefox"
fi

if [ $INSTALL_CHROME == true ]; then
  display "Start chrome"
  paru -Syu --noconfirm google-chrome
  log "End chrome"
fi

if [ $INSTALL_BRAVE == true ]; then
  display "Start Brave"
  paru -Syu --noconfirm brave-bin
  log "End Brave"
fi

if [ $INSTALL_VSCODE == true ]; then
  display "Start VSCode"
  sudo paru -Syu --noconfirm code
  log "End VSCode"
fi

if [ $INSTALL_VSCODIUM == true ]; then
  display "Start VSCodium"
  paru -Syu --noconfirm vscodium
  log "End VSCodium"
fi

if [ $INSTALL_JETBRAINS == true ]; then
  display "Start VSCodium"
  paru -Syu --noconfirm jetbrains-toolbox
  log "End VSCodium"
fi

if [ $INSTALL_NVIM == true ]; then
  display "Start Neovim"
  sudo paru -Syu --noconfirm neovim
  log "End Neovim"

  display "Start Config NeoVim"
  if [ ! -d "$HOME/.config/nvim" ]; then
    pip install neovim --break-system-packages
    if [ ! "$(command -v tree-sitter)" ]; then
      sudo npm install -g neovim tree-sitter-cli
    fi
    sudo paru -Syu --noconfirm xclip
    git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
  fi
  log "End Config NeoVim"
fi

sudo chown -R "$USER":"$USER" "/home/$USER"

END=$(date +%s)

RUNTIME=$((END - START))

display "Type Your Password to make zsh your Default shell"
chsh -s /bin/zsh

display "Scrip executed in $RUNTIME s"

display "Reboot Now"

# Log script completion
log "Installation script completed."
