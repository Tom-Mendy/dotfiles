#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/detect-os.sh"

if command -v git > /dev/null 2>&1; then
  log "git déjà installé"
  exit 0
fi

log "Installation de git pour ${DISTRO}${auth_msg}"

case "$DISTRO" in
  arch)
    if [[ $EUID -eq 0 ]]; then
      pacman -Sy --noconfirm git
    else
      sudo pacman -Sy --noconfirm git
    fi
    ;;
  debian | ubuntu)
    if [[ $EUID -eq 0 ]]; then
      apt-get update -y
      apt-get install -y git
    else
      sudo apt-get update -y
      sudo apt-get install -y git
    fi
    ;;
  fedora)
    if [[ $EUID -eq 0 ]]; then
      dnf install -y git
    else
      sudo dnf install -y git
    fi
    ;;
  nixos)
    nix-env -iA nixos.git
    ;;
  macos)
    if command -v brew > /dev/null 2>&1; then
      brew install git
    else
      warn "Homebrew non installé — installez-le puis relancez."
      exit 1
    fi
    ;;
  wsl)
    if command -v apt-get > /dev/null 2>&1; then
      if [[ $EUID -eq 0 ]]; then
        apt-get update -y
        apt-get install -y git
      else
        sudo apt-get update -y
        sudo apt-get install -y git
      fi
    else
      warn "WSL détecté mais aucun gestionnaire apt trouvé. Installez git manuellement."
      exit 1
    fi
    ;;
  *)
    die "Distribution non supportée : ${DISTRO}"
    ;;
esac

log "✔ git installé"
