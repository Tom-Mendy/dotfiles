#!/bin/bash

echo "FONT"
git clone https://github.com/ryanoasis/nerd-fonts.git /tmp/nerd-fonts
cd /tmp/nerd-fonts
./install.sh
cd 
sudo rm -rf /tmp/nerd-fonts