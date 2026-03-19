#!/usr/bin/env bash
set -euo pipefail

# Prevent re-detection when already sourced
if [[ -n ${OS:-} && -n ${DISTRO:-} ]]; then
  return 0 2> /dev/null || exit 0
fi

OS="unknown"
DISTRO="unknown"
IS_WSL=0

case "${OSTYPE:-}" in
  linux-gnu* | linux*)
    OS="linux"
    if grep -qi microsoft /proc/version 2> /dev/null; then
      IS_WSL=1
      DISTRO="wsl"
    elif [[ -f /etc/os-release ]]; then
      . /etc/os-release
      DISTRO=${ID:-linux}
    fi
    ;;
  darwin*)
    OS="mac"
    DISTRO="macos"
    ;;
  *)
    OS="unknown"
    DISTRO="unknown"
    ;;
esac

auth_msg=""
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  auth_msg=" (sudo may be required for package installs)"
fi

export OS DISTRO IS_WSL auth_msg
