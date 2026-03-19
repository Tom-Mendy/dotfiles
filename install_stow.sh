#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/detect-os.sh"

if command -v stow > /dev/null 2>&1; then
  log "stow déjà installé"
  exit 0
fi

log "Installation de stow pour ${DISTRO}${auth_msg}"

case "$DISTRO" in
  arch)
    sudo pacman -Sy --noconfirm stow
    ;;
  debian|ubuntu)
    sudo apt-get update -y
    sudo apt-get install -y stow
    ;;
  fedora)
    sudo dnf install -y stow
    ;;
  nixos)
    nix-env -iA nixos.stow
    ;;
  macos)
    if command -v brew > /dev/null 2>&1; then
      brew install stow
    else
      warn "Homebrew non installé — installez-le puis relancez."
      exit 1
    fi
    ;;
  wsl)
    if command -v apt-get > /dev/null 2>&1; then
      sudo apt-get update -y
      sudo apt-get install -y stow
    else
      warn "WSL détecté mais aucun gestionnaire apt trouvé. Installez stow manuellement."
      exit 1
    fi
    ;;
  *)
    die "Distribution non supportée : ${DISTRO}"
    ;;
esac

log "✔ stow installé"
