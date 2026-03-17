#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/utils.sh"

CACHE_DIR="$HOME/.cache/dotfiles"
REPO_CACHE_DIR="$ROOT_DIR/cache"
mkdir -p "$CACHE_DIR" "$REPO_CACHE_DIR"

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

# Zinit (plugin manager) with optional offline tarball
ZINIT_REPO="https://github.com/zdharma-continuum/zinit"
ZINIT_DIR="$HOME/.zinit/bin"
ZINIT_TAR="$REPO_CACHE_DIR/zinit.tar.gz"
ZINIT_SHA="$ZINIT_TAR.sha256"

use_tarball() {
  local tarball="$1"
  local checksum="$2"
  local dest="$3"

  if [[ -f $tarball && -f $checksum ]]; then
    if (cd "$(dirname "$tarball")" && sha256sum -c "$(basename "$checksum")"); then
      log "Using offline cache $(basename "$tarball")"
      rm -rf "$dest"
      mkdir -p "$dest"
      tar -xzf "$tarball" -C "$dest"
      return 0
    else
      warn "Checksum failed for $(basename "$tarball"); ignoring cache."
    fi
  fi
  return 1
}

if ! use_tarball "$ZINIT_TAR" "$ZINIT_SHA" "$ZINIT_DIR"; then
  clone_or_update "$ZINIT_REPO" "$ZINIT_DIR"
fi

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
