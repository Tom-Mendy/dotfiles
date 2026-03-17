#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="$ROOT/artifacts"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
BENCH_DIR="$CACHE_DIR/zsh-bench"

mkdir -p "$ARTIFACT_DIR" "$CACHE_DIR"

if [[ ! -d "$BENCH_DIR/.git" ]]; then
  echo "[bench] cloning zsh-bench into cache" >&2
  rm -rf "$BENCH_DIR"
  git clone --depth=1 https://github.com/romkatv/zsh-bench "$BENCH_DIR"
else
  echo "[bench] updating zsh-bench" >&2
  git -C "$BENCH_DIR" pull --ff-only || true
fi

OUT_TXT="$ARTIFACT_DIR/zsh-bench.txt"
OUT_MD="$ARTIFACT_DIR/zsh-bench.md"

ZDOTDIR="$ROOT/zsh" "$BENCH_DIR"/zsh-bench | tee "$OUT_TXT"

{
  echo "# zsh-bench"
  echo
  echo '```'
  cat "$OUT_TXT"
  echo '```'
} > "$OUT_MD"

echo "[bench] report generated at $OUT_MD"
