#!/bin/bash

input="vscode-extensions.txt"
while IFS= read -r line
do
  codium --install-extension $line --force
done < "$input"