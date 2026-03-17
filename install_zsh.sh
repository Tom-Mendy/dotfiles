#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"
source "$SCRIPT_DIR/scripts/detect-os.sh"

log "Detected OS: $OS (${DISTRO})"

run_parallel \
  "$SCRIPT_DIR/scripts/zsh/install-deps.sh" \
  "$SCRIPT_DIR/scripts/zsh/install-tools.sh"

# wait is handled inside run_parallel via wait loop

"$SCRIPT_DIR/scripts/zsh/install-completions.sh"

stow -t "${HOME}" -d "${SCRIPT_DIR}" -v -R -S zsh

log "✔ Installation completed"
