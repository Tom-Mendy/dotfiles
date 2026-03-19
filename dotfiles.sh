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
DRY_RUN=0
STOW_DIRS=(hypr vim nvim nushell bash tmux zsh wofi rofi ghostty)

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [dir1 dir2 ...]"
      exit 0
      ;;
    *)
      STOW_DIRS=("$@")
      break
      ;;
  esac
done

for dir in "${STOW_DIRS[@]}"; do
  if [[ -d "$SCRIPT_DIR/$dir" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
      log "Would stow: $dir"
    else
      stow -t "${HOME}" -d "${SCRIPT_DIR}" -v -R -S "$dir"
    fi
  else
    warn "Missing directory, skipped: $dir"
  fi
done

# tmux plugin manager
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

log "Dotfiles installés"
