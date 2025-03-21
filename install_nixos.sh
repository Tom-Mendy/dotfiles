#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

sudo cp "${SCRIPT_DIR}/nix/configuration.nix" "/etc/nixos/configuration.nix"

sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
sudo nix-channel --update

sudo nixos-rebuild switch

rustup default stable
sudo rustup default stable
