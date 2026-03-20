#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
source "${SCRIPT_DIR}/scripts/utils.sh"
source "${SCRIPT_DIR}/scripts/detect-os.sh"

log "Detected OS: $OS (${DISTRO})"

"${SCRIPT_DIR}/scripts/zsh/install-deps.sh"
"${SCRIPT_DIR}/scripts/zsh/install-tools.sh"
"${SCRIPT_DIR}/scripts/zsh/install-completions.sh"

install_packages stow

if [ -f "${HOME}/.zshrc" ] && [ ! -L "${HOME}/.zshrc" ]; then
  mv "${HOME}/.zshrc" "${HOME}/.zshrc.backup"
  echo "Backed up existing .zshrc to .zshrc.backup"
fi
stow -t "${HOME}" -d "${SCRIPT_DIR}" -v -R -S zsh

log "✔ Installation completed"
