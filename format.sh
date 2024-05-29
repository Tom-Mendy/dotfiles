#!/bin/bash

# grep_str="^.*.[c]$"

# zappy_server="$(find "$(pwd)/Zappy_server" -maxdepth 5 -type f -not -path '*/\.*' | grep "$grep_str")"
# clang-format -i $zappy_server

# find ZappyAI -name '*.py' -exec python3 -m autopep8 --in-place --aggressive --aggressive {} \;

grep_str_sh="^.*.[s][h]$"

bash_files="$(find "$(pwd)/" -maxdepth 5 -type f -not -path '*/\.*' | grep "$grep_str_sh")"
shfmt -l -w $bash_files