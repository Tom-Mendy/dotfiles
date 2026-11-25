#!/bin/sh
# blaze looks for its toolchain (its standard library and sysroot) only under
# $HOME/.blaze/v2/toolchain. The store copy is read-only, so install it there
# on first use. Later runs skip the copy, and a newer blaze replaces it via its
# own pinned manifest.
set -eu

shelf="@shelf@"
real="@real@"
pinned="@pinned@"

if [ -n "${HOME:-}" ] && [ ! -e "$HOME/.blaze/v2/toolchain/$pinned" ]; then
  mkdir -p "$HOME/.blaze/v2/toolchain"
  for f in "$shelf"/*; do
    base=${f##*/}
    if [ ! -e "$HOME/.blaze/v2/toolchain/$base" ]; then
      cp --no-preserve=mode "$f" "$HOME/.blaze/v2/toolchain/$base"
      chmod 0444 "$HOME/.blaze/v2/toolchain/$base"
    fi
  done
fi

exec "$real" "$@"
