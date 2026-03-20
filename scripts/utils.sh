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

auto_sudo() {
  # Usage: auto_sudo <command> [args...]
  if [[ $EUID -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_packages() {
  # Usage: install_packages <package1> [package2 ...]
  local packages=("$@")
  if [[ ${#packages[@]} -lt 1 ]]; then
    warn "install_packages: no package specified"
    return 1
  fi
  case "$DISTRO" in
    arch)
      auto_sudo pacman -Sy --noconfirm "${packages[@]}"
      ;;
    debian | ubuntu)
      auto_sudo apt-get update -y
      auto_sudo apt-get install -y "${packages[@]}"
      ;;
    fedora)
      auto_sudo dnf install -y "${packages[@]}"
      ;;
    nixos)
      for pkg in "${packages[@]}"; do
        nix-env -iA "nixos.$pkg"
      done
      ;;
    macos)
      if command -v brew > /dev/null 2>&1; then
        brew install "${packages[@]}"
      else
        warn "Homebrew non installé — installez-le puis relancez."
        return 1
      fi
      ;;
    wsl)
      local pkg_managers=(apt-get pacman dnf)
      local installed=false
      for pm in "${pkg_managers[@]}"; do
        if command -v "$pm" > /dev/null 2>&1; then
          case "$pm" in
            apt-get)
              auto_sudo apt-get update -y && auto_sudo apt-get install -y "${packages[@]}"
              ;;
            pacman)
              auto_sudo pacman -Sy --noconfirm "${packages[@]}"
              ;;
            dnf)
              auto_sudo dnf install -y "${packages[@]}"
              ;;
          esac
          installed=true
          break
        fi
      done
      if ! $installed; then
        warn "WSL détecté mais aucun gestionnaire compatible trouvé. Installez les packages manuellement: ${packages[*]}"
        return 1
      fi
      ;;
    *)
      die "Distribution non supportée : $DISTRO"
      return 1
      ;;
  esac
}
