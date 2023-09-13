#!/usr/bin/bash

sudo nala update && sudo nala upgrade -y
flatpak update -y
npm update -y
cargo update -y