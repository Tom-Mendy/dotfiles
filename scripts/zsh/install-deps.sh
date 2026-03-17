#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/utils.sh"
source "$ROOT_DIR/detect-os.sh"

PACKAGES=(git curl zsh fzf bat eza)

install_apt() {
  log "Installing base packages via apt${auth_msg}"
  sudo apt-get update -y
  sudo apt-get install -y "${PACKAGES[@]}" ca-certificates
}

install_dnf() {
  log "Installing base packages via dnf${auth_msg}"
  sudo dnf install -y "${PACKAGES[@]}" ca-certificates
}

install_pacman() {
  log "Installing base packages via pacman${auth_msg}"
  sudo pacman -Sy --noconfirm "${PACKAGES[@]}" ca-certificates
}

install_brew() {
  if ! command -v brew > /dev/null; then
    warn "Homebrew non installé — saute (installer Brew puis relancer)."
    return
  fi
  log "Installing base packages via Homebrew"
  brew install "${PACKAGES[@]}"
}

case "$OS" in
  linux)
    if command -v apt-get > /dev/null; then
      install_apt
    elif command -v dnf > /dev/null; then
      install_dnf
    elif command -v pacman > /dev/null; then
      install_pacman
    else
      warn "Aucun gestionnaire de paquets supporté détecté (apt/dnf/pacman)."
    fi
    ;;
  mac)
    install_brew
    ;;
  *)
    warn "OS inconnu : saute l'installation des dépendances système."
    ;;
esac
