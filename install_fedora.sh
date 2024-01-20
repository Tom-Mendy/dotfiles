#!/bin/bash

# Enable exit on error
set -e

# Function to log messages
log() {
  local message="$1"
  sudo sh -c "echo \"$(date +'%Y-%m-%d %H:%M:%S') $message\" >> \"$LOG_FILE\""
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
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"
mkdir -p "$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures" "$HOME/Music"
mkdir -p "$HOME/.config/"

# Update Submodule
git submodule update --init --recursive
# copy my scripts
cp "$SCRIPT_DIR/my_scripts" "$HOME"

# Update DNF
sudo "$SCRIPT_DIR/dnf/dnf.conf" /etc/dnf/dnf.conf

# default APP
sudo dnf install -y htop vim curl figlet neofetch
sudo dnf group install -y 'Development Tools'

display "ZSH"
if [ ! "$(command -v zsh)" ]; then
  sudo dnf install -y zsh fontawesome-fonts
  cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
  mkdir "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
  touch "$HOME/.zsh/kubectl.zsh"
  cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

display "Start Flatpak"
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "End Flatpak"

display "Start Rust"
if [ ! "$(command -v cargo)" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rust.sh
  chmod +x /tmp/rust.sh
  /tmp/rust.sh -y
  rm -f /tmp/rust.sh
  source "$HOME/.cargo/env"
fi
log "End Rust"

display "Start Nodejs"
sudo dnf install -y nodejs
log "End Nodejs"

display "Go Start"
sudo dnf install -y golang
display "Go End"

display "Python"
sudo dnf install -y python3-pip
display "Python"

display "Java Start"
sudo dnf install -y java
display "Java End"

display "C Start"
sudo dnf group install -y 'C Development Tools and Libraries'
sudo dnf install -y ghc-criterion
//"$SCRIPT_DIR/criterion/install_criterion.sh"
display "C End"


display "Docker Engine Start"
if [ ! "$(command -v docker)" ]; then
  sudo dnf -y install dnf-plugins-core
  sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
  sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  if ! getent group docker >/dev/null; then
    echo "Creating group: docker"
    sudo groupadd docker
  fi
  sudo usermod -aG docker "$USER"
fi

display "Start Terminal Emulators"
sudo dnf install -y kitty
mkdir -p "$HOME/.config/kitty/"
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"
#make kitty the default terminal
sudo update-alternatives --set x-terminal-emulator /usr/bin/kitty
log "End Terminal Emulators"

display "Start Modern replacement"
cargo install eza fcp
sudo npm i -g safe-rm
sudo dnf install -y tldr bat ripgrep fzf fd-find
log "End Modern replacement"

display "Start File Managers"
# terminal base
if [ ! "$(command -v yazi)" ]; then
  cargo install --locked yazi-fm
fi
# GUI
if [ ! "$(command -v thunar)" ]; then
  sudo dnf install -y thunar thunar-archive-plugin thunar-media-tags-plugin
  mkdir -p "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
  cp "$SCRIPT_DIR/Thunar/thunar.xml" "$HOME/.config/xfce4/xfconf/xfce-perchannel-xml/"
  mkdir -p "$HOME/.config/Thunar"
  cp "$SCRIPT_DIR/Thunar/uca.xml" "$HOME/.config/Thunar"
  cp "$SCRIPT_DIR/Thunar/accels.scm" "$HOME/.config/Thunar"
fi
log "End File Managers"

display "Start Bluetooth Support"
sudo dnf install -y bluez blueman
sudo systemctl enable bluetooth
log "End Bluetooth Support"

display "Start Communication"
# discord
if [ ! "$(command -v Discord)" ]; then
  sudo flatpak install -y flathub com.discordapp.Discord
fi
# teams for linux
if [ ! "$(command -v teams-for-linux)" ]; then
  sudo flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
fi
log "End Communication"

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
dnf check-update
sudo dnf -y install code

display "Start Config NeoVim"
if [ ! -d "$HOME/.config/nvim" ]; then
  pip install neovim --break-system-packages
  if [ ! "$(command -v tree-sitter)" ]; then
    sudo npm install -g neovim tree-sitter-cli
  fi
  sudo dnf install -y xclip
  git clone https://github.com/Tom-Mendy/nvim.git "$HOME/.config/nvim"
  # make .$HOME/.config/nvim work great for root
  sudo cp -r "$HOME/.config/nvim" /root/.config/nvim
  # make nvim the default editor
  sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 50
fi
log "End Config NeoVim"

d
