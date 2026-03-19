#!/usr/bin/env bash

# grep_str="^.*.[c]$"

# zappy_server="$(find "$(pwd)/Zappy_server" -maxdepth 5 -type f -not -path '*/\.*' | grep "$grep_str")"
# clang-format -i $zappy_server

# find ZappyAI -name '*.py' -exec python3 -m autopep8 --in-place --aggressive --aggressive {} \;

grep_str_sh="^.*[.][s][h]$"

find "$(pwd)/" -maxdepth 5 -type f -not -path '*/\.*' |
  grep "$grep_str_sh" |
  xargs -r shfmt -l -w -s -i 2 -ci -sr
