#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_SCRIPTS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_SCRIPTS_DIR/utils.sh"

ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
COMP_DIR="$ZSH_CACHE_DIR/completions"
mkdir -p "$COMP_DIR"

mk_completion() {
  local cmd="$1"
  local file="$2"
  if command -v "$cmd" > /dev/null && [[ ! -f $file ]]; then
    log "Generating completion for $cmd"
    "$cmd" completion zsh > "$file" 2> /dev/null || warn "Impossible de générer la complétion $cmd"
  fi
}

mk_completion docker "$COMP_DIR/_docker"
mk_completion kubectl "$COMP_DIR/_kubectl"
mk_completion bun "$COMP_DIR/_bun"

# GitHub CLI (gh)
if command -v gh > /dev/null && [[ ! -f "$COMP_DIR/_gh" ]]; then
  log "Generating completion for gh"
  gh completion -s zsh > "$COMP_DIR/_gh" 2> /dev/null || true
fi

# Angular CLI (ng)
if command -v ng > /dev/null && [[ ! -f "$COMP_DIR/_ng" ]]; then
  log "Generating completion for ng"
  ng completion script > "$COMP_DIR/_ng" 2> /dev/null || true
fi
