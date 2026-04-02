#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_SCRIPTS_DIR/utils.sh"
source "$ROOT_SCRIPTS_DIR/detect-os.sh"

PACKAGES=(git curl zsh fzf bat ripgrep)

install_packages "${PACKAGES[@]}"

# Install Eza from Binary for latest version
install_eza() {
  if command -v eza > /dev/null; then
    log "eza already installed"
    return
  fi
  log "Installing eza from pre-built binary..."
  # You can override version and arch via environment variables
  # Detect architecture
  ARCH=$(uname -m)
  case "${ARCH}" in
    x86_64)
      EZA_ARCH="x86_64-unknown-linux-gnu"
      ;;
    aarch64)
      EZA_ARCH="aarch64-unknown-linux-gnu"
      ;;
    *)
      warn "Unknown architecture "${ARCH}", defaulting to x86_64-unknown-linux-gnu"
      EZA_ARCH="x86_64-unknown-linux-gnu"
      ;;
  esac

  # Fetch latest release asset URL from GitHub API
  EZA_API_URL="https://api.github.com/repos/eza-community/eza/releases/latest"
  ASSET_URL=$(curl -sSfL "${EZA_API_URL}" | grep browser_download_url | grep "${EZA_ARCH}" | grep '.tar.gz' | head -n1 | cut -d '"' -f4)
  if [[ -z ${ASSET_URL} ]]; then
    warn "Could not find a suitable eza binary for ${EZA_ARCH}. Falling back to v0.23.4."
    EZA_VERSION="v0.23.4"
    ASSET_URL="https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_${EZA_ARCH}.tar.gz"
  else
    # Extract version from asset URL if possible
    EZA_VERSION=$(echo "${ASSET_URL}" | grep -oP 'download/\K[^/]+' || echo "unknown")
  fi
  TMP_DIR="$(mktemp -d)"
  curl -sSfL "${ASSET_URL}" -o "$TMP_DIR/eza.tar.gz"
  tar -xzf "$TMP_DIR/eza.tar.gz" -C "$TMP_DIR"
  auto_sudo mv "$TMP_DIR/eza" /usr/local/bin/eza
  auto_sudo chmod +x /usr/local/bin/eza
  rm -rf "$TMP_DIR"
  log "✔ eza installed from pre-built binary (${EZA_VERSION:-unknown}, ${EZA_ARCH})"
}

install_eza
