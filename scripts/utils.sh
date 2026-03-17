#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "\033[1;32m[dotfiles]\033[0m %s\n" "$1"
}

warn() {
  printf "\033[1;33m[warn]\033[0m %s\n" "$1" >&2
}

die() {
  printf "\033[1;31m[error]\033[0m %s\n" "$1" >&2
  exit 1
}

run_parallel() {
  # run multiple scripts in parallel and propagate failure
  pids=()
  for cmd in "$@"; do
    bash "$cmd" &
    pids+=("$!")
  done

  status=0
  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      status=1
    fi
  done

  return "$status"
}
