#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/detect-os.sh"

if command -v curl > /dev/null 2>&1; then
  log "curl déjà installé"
  exit 0
fi

log "Installation de curl pour ${DISTRO}${auth_msg}"

case "$DISTRO" in
  arch)
    if [[ $EUID -eq 0 ]]; then
      pacman -Sy --noconfirm curl
    else
      sudo pacman -Sy --noconfirm curl
    fi
    ;;
  debian | ubuntu)
    if [[ $EUID -eq 0 ]]; then
      apt-get update -y
      apt-get install -y curl
    else
      sudo apt-get update -y
      sudo apt-get install -y curl
    fi
    ;;
  fedora)
    if [[ $EUID -eq 0 ]]; then
      dnf install -y curl
    else
      sudo dnf install -y curl
    fi
    ;;
  nixos)
    nix-env -iA nixos.curl
    ;;
  macos)
    if command -v brew > /dev/null 2>&1; then
      brew install curl
    else
      warn "Homebrew non installé — installez-le puis relancez."
      exit 1
    fi
    ;;
  wsl)
    if command -v apt-get > /dev/null 2>&1; then
      if [[ $EUID -eq 0 ]]; then
        apt-get update -y
        apt-get install -y curl
      else
        sudo apt-get update -y
        sudo apt-get install -y curl
      fi
    else
      warn "WSL détecté mais aucun gestionnaire apt trouvé. Installez curl manuellement."
      exit 1
    fi
    ;;
  *)
    die "Distribution non supportée : ${DISTRO}"
    ;;
esac

log "✔ curl installé"
