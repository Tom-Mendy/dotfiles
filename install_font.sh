#!/bin/bash

echo "FONT"
git clone https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
cd /tmp/nerd-fonts || exit 1
./install.sh
cd || exit 1
sudo rm -rf /tmp/nerd-fonts