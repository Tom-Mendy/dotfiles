#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_SCRIPTS_DIR/utils.sh"
install_packages git curl

CACHE_DIR="$HOME/.cache/dotfiles"
REPO_CACHE_DIR="$ROOT_SCRIPTS_DIR/cache"
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
  bash "$script"

  log "zoxide installed successfully"
}

install_atuin() {
  if command -v atuin > /dev/null; then
    return
  fi

  local script="$CACHE_DIR/atuin-installer.sh"
  if [[ ! -f $script ]]; then
    log "Fetching atuin installer"
    curl -sSfL https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh -o "$script"
  else
    log "Using cached atuin installer"
  fi

  sh "$script"

  log "atuin installed successfully"
}

install_sesh() {
  if command -v sesh > /dev/null; then
    log "sesh already installed"
    return
  fi

  log "Installing sesh from pre-built binary or Go..."

  ARCH=$(uname -m)
  OS=$(uname -s)
  case "${ARCH}" in
    x86_64)
      SESH_ARCH="x86_64"
      ;;
    aarch64)
      SESH_ARCH="aarch64"
      ;;
    *)
      warn "Unknown architecture ${ARCH}, trying Go install fallback"
      if command -v go > /dev/null; then
        go install github.com/joshmedeski/sesh/v2@latest
        log "✔ sesh installed via Go"
        return
      fi
      die "Cannot install sesh: unsupported architecture and Go not found"
      ;;
  esac

  OS_LOWER=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
  SESH_API_URL="https://api.github.com/repos/joshmedeski/sesh/releases/latest"
  ASSET_URL=$(curl -sSfL "${SESH_API_URL}" | grep browser_download_url | grep "${OS_LOWER}" | grep "${SESH_ARCH}" | grep -v '.sha256' | head -n1 | cut -d '"' -f4)

  if [[ -z ${ASSET_URL} ]]; then
    warn "No binary release for ${OS_LOWER}/${SESH_ARCH}, trying Go install"
    if command -v go > /dev/null; then
      go install github.com/joshmedeski/sesh/v2@latest
      log "✔ sesh installed via Go"
      return
    else
      warn "Go not found, sesh install skipped"
      return
    fi
  fi

  TMP_DIR="$(mktemp -d)"
  curl -sSfL "${ASSET_URL}" -o "$TMP_DIR/sesh.tar.gz" || curl -sSfL "${ASSET_URL}" -o "$TMP_DIR/sesh.zip"

  if [[ -f "$TMP_DIR/sesh.tar.gz" ]]; then
    tar -xzf "$TMP_DIR/sesh.tar.gz" -C "$TMP_DIR"
  elif [[ -f "$TMP_DIR/sesh.zip" ]]; then
    unzip -q "$TMP_DIR/sesh.zip" -d "$TMP_DIR"
  fi

  auto_sudo mv "$TMP_DIR/sesh" /usr/local/bin/sesh 2> /dev/null || auto_sudo cp "$TMP_DIR/sesh" /usr/local/bin/sesh
  auto_sudo chmod +x /usr/local/bin/sesh
  rm -rf "$TMP_DIR"
  log "✔ sesh installed"
}

install_zoxide
install_atuin
install_sesh
