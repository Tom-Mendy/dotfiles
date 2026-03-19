#!/usr/bin/env bash
set -euo pipefail

# Documentation
# https://www.gnu.org/software/stow/manual/stow.html

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "$SCRIPT_DIR/scripts/utils.sh"

# Avoid running as root to prevent writing configs in /root
if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  die "Ne pas lancer en root"
fi

if ! command -v stow > /dev/null 2>&1; then
  "$SCRIPT_DIR/install_stow.sh"
fi

# Only stow directories that actually exist in the repo
STOW_DIRS=(hypr vim nvim nushell bash tmux zsh wofi rofi ghostty)
for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "$SCRIPT_DIR/$dir" ]]; then
    stow -t "${HOME}" -d "${SCRIPT_DIR}" -v -R -S "$dir"
  else
    warn "Répertoire manquant, ignoré: $dir"
  fi
done

# tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

log "Dotfiles installés"
