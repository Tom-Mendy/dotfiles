#!/bin/bash

mkdir -p ~/.config/VSCodium/User/
cp settings.json ~/.config/VSCodium/User/settings.json

input="vscode-extensions.txt"
while IFS= read -r line; do
  codium --install-extension $line --force
done < "$input"
