#!/usr/bin/bash

echo "nala"
sudo nala update && sudo nala upgrade -y
echo "npm"
npm update -y
echo "rustup"
rustup update
echo "flatpak"
flatpak update -y