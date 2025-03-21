#!/usr/bin/env bash

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
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
CRONTAB_ROOT="$SCRIPT_DIR/crontab/root"

# define what you want to install
INSTALL_MY_SCRIPT=true
INSTALL_JAVA=true
INSTALL_GO=true
INSTALL_C=true
INSTALL_HASKELL=true
INSTALL_DOCKER=true
INSTALL_TUI_FILE_MANAGER=true
INSTALL_BRAVE=false
INSTALL_CHROME=true
INSTALL_VSCODE=true
# only if you are using i3
INSTALL_I3=false

# Update Submodule
if [ $INSTALL_MY_SCRIPT == true ]; then
  if [ ! -d "/tmp/auto_set_bing_wallpaper" ]; then
    git clone https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git "/tmp/auto_set_bing_wallpaper"
    cp "/tmp/auto_set_bing_wallpaper/auto_wallpaper.sh" "$SCRIPT_DIR/my_scripts"
  fi
  # copy my scripts
  cp -r "$SCRIPT_DIR/my_scripts" "$HOME"
fi

# Update DNF
sudo cp "$SCRIPT_DIR/dnf/dnf.conf" /etc/dnf/dnf.conf
sudo dnf update -y
# enable auto update
sudo dnf install -y dnf-automatic
sudo systemctl enable --now dnf-automatic-install.timer

# default APP
sudo dnf install -y htop vim curl figlet neofetch rofi
sudo dnf group install -y 'Development Tools'

# Remove PC Speaker Beep
sudo rmmod pcspkr

display "ZSH"
if [ ! "$(command -v zsh)" ]; then
  sudo dnf install -y zsh fontawesome-fonts
  cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"
  mkdir "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/alias.zsh" "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/env.zsh" "$HOME/.zsh"
  cp "$SCRIPT_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

display "Start Flatpak"
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "End Flatpak"

display "Start Rust"
if [ ! "$(command -v cargo)" ]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs >/tmp/rust.sh
  chmod +x /tmp/rust.sh
  /tmp/rust.sh -y
  rm -f /tmp/rust.sh
  source "$HOME/.cargo/env"
fi
log "End Rust"

display "Start Nodejs"
sudo dnf install -y nodejs
log "End Nodejs"

if [ $INSTALL_GO == true ]; then
  display "Start Go"
  sudo dnf install -y golang
  log "End Go"
fi

display "Start Python"
sudo dnf install -y python3-pip
log "Start Python"

if [ $INSTALL_JAVA == true ]; then
  display "Start Java"
  sudo dnf install -y java
  log "End Java"
fi

if [ $INSTALL_C == true ]; then
  display "Start C"
  sudo dnf install -y gcovr clang ncurses-devel SFML-devel
  sudo dnf group install -y 'C Development Tools and Libraries'
  "$SCRIPT_DIR/criterion/install_criterion.sh"
  log "End C"
fi

if [ $INSTALL_HASKELL == true ]; then
  display "Start Haskell"
  sudo dnf install -y stack
  sudo stack upgrade
  stack install stylish-haskell hindent ghc hlint
  # curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
  log "End Haskell"
fi

if [ $INSTALL_DOCKER == true ]; then
  display "Start Docker Engine"
  if [ ! "$(command -v docker)" ]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    if ! getent group docker >/dev/null; then
      echo "Creating group: docker"
      sudo groupadd docker
    fi
    sudo usermod -aG docker "$USER"
    sudo systemctl enable containerd.service
    sudo systemctl enable docker.service
  fi
  log "End Docker Engine"
fi

display "Start Terminal Emulators"
sudo dnf install -y kitty
mkdir -p "$HOME/.config/kitty/"
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"
log "End Terminal Emulators"

display "Start Modern replacement"
cargo install eza fcp
sudo npm i -g safe-rm
sudo dnf install -y tldr bat ripgrep fzf fd-find
log "End Modern replacement"

display "Start More icons"
if [ ! -d "/tmp/devicons" ]; then
  git clone https://github.com/vorillaz/devicons.git "/tmp/devicons"
  sudo cp /tmp/devicons/fonts/devicons.ttf /usr/share/fonts/
  fc-cache -f -v
fi
log "End More icons"

if [ $INSTALL_I3 == true ]; then
  display "Start i3"
  sudo dnf install -y i3 xautolock picom feh parcellite
  if [ ! -d "/tmp/i3lock-fancy" ]; then
    git clone https://github.com/meskarune/i3lock-fancy.git "/tmp/i3lock-fancy"
    cd "/tmp/i3lock-fancy"
    sudo make install
    cd -
  fi
  mkdir -p "$HOME/.config/i3/"
  cp "$SCRIPT_DIR/i3/"* "$HOME/.config/i3/"
  mkdir -p "$HOME/.config/rofi/"
  cp "$SCRIPT_DIR/rofi/"* "$HOME/.config/rofi/"
  log "End i3"
fi

if [ $INSTALL_TUI_FILE_MANAGER == true ]; then
  display "Start File Managers"
  # terminal base
  if [ ! "$(command -v yazi)" ]; then
    cargo install --locked yazi-fm
  fi
  log "End File Managers"
fi

display "Start Communication"
# discord
if [ ! "$(command -v com.discordapp.Discord)" ]; then
  sudo flatpak install -y flathub com.discordapp.Discord
fi
# teams for linux
if [ ! "$(command -v com.github.IsmaelMartinez.teams_for_linux)" ]; then
  sudo flatpak install -y flathub com.github.IsmaelMartinez.teams_for_linux
fi
log "End Communication"

if [ $INSTALL_BRAVE == true ]; then
  display "Start Brave"
  if [ ! "$(command -v brave-brower)" ]; then
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    sudo dnf install -y brave-browser
  fi
  log "End Brave"
fi

if [ $INSTALL_CHROME == true ]; then
  display "Start Chrome"
  if [ ! "$(command -v google-chrome-stable)" ]; then
    sudo dnf install fedora-workstation-repositories
    sudo dnf config-manager --set-enabled google-chrome
    sudo dnf install -y google-chrome-stable
  fi
  log "End Chrome"
fi

if [ $INSTALL_VSCODE == true ]; then
  display "Start VSCode"
  if [ ! "$(command -v code)" ]; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
    dnf check-update
    sudo dnf -y install code
  fi
  log "End VSCode"
fi

chsh -s /bin/bash
