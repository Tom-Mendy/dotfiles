#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/utils.sh"

CACHE_DIR="$HOME/.cache/dotfiles"
mkdir -p "$CACHE_DIR"

clone_or_update() {
  local repo="$1"
  local dest="$2"
  local ref="${3:-}"

  if [[ -d "$dest/.git" ]]; then
    log "Updating $(basename "$dest")"
    # Avoid interactive strategy prompts; prefer fast-forward-only to keep local tree clean.
    git -C "$dest" pull --ff-only || warn "Pull failed for $repo, keeping existing copy"
  else
    log "Cloning $(basename "$dest")"
    git clone --depth=1 ${ref:+--branch "$ref"} "$repo" "$dest"
  fi
}

# Zinit (plugin manager)
ZINIT_REPO="https://github.com/zdharma-continuum/zinit"
ZINIT_DIR="$HOME/.zinit/bin"
clone_or_update "$ZINIT_REPO" "$ZINIT_DIR"

# Zoxide (cached installer)
install_zoxide() {
  if command -v zoxide > /dev/null; then
    return
  fi

  local script="$CACHE_DIR/zoxide-install.sh"
  if [[ ! -f $script ]]; then
    log "Fetching zoxide installer"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh -o "$script"
  else
    log "Using cached zoxide installer"
  fi
  bash "$script" --yes
}

install_zoxide
