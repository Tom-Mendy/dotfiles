#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_DIR="$ROOT/artifacts"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
BENCH_DIR="$CACHE_DIR/zsh-bench"
# Optional: pin zsh-bench commit for stability (set ZSH_BENCH_REF to a valid hash)
ZSH_BENCH_REF="${ZSH_BENCH_REF:-}"
# Jobs flag disabled because some zsh-bench revisions don't support -j; keep env for future
JOBS="${ZSH_BENCH_JOBS:-}"

mkdir -p "$ARTIFACT_DIR" "$CACHE_DIR"

if [[ ! -d "$BENCH_DIR/.git" ]]; then
  echo "[bench] cloning zsh-bench into cache" >&2
  rm -rf "$BENCH_DIR"
  git clone --depth=1 https://github.com/romkatv/zsh-bench "$BENCH_DIR"
else
  echo "[bench] updating zsh-bench" >&2
  git -C "$BENCH_DIR" pull --ff-only || true
fi
if [[ -n "$ZSH_BENCH_REF" ]]; then
  git -C "$BENCH_DIR" checkout -q "$ZSH_BENCH_REF" || echo "[bench] warning: cannot checkout $ZSH_BENCH_REF"
fi

OUT_TXT="$ARTIFACT_DIR/zsh-bench.txt"
OUT_MD="$ARTIFACT_DIR/zsh-bench.md"

run_once() {
  local label="$1"
  local outfile="$2"
  ZDOTDIR="$ROOT/zsh" "$BENCH_DIR"/zsh-bench | tee "$outfile"
}

echo "[bench] cold run..."
run_once "cold" "$OUT_TXT"

echo "[bench] warm run..."
OUT_TXT_WARM="$ARTIFACT_DIR/zsh-bench-warm.txt"
run_once "warm" "$OUT_TXT_WARM"

# Extract exit_time_ms as total
parse_exit_ms() {
  awk -F= '/^exit_time_ms=/ {print $2}' "$1" | head -n1
}

COLD_MS=$(parse_exit_ms "$OUT_TXT")
WARM_MS=$(parse_exit_ms "$OUT_TXT_WARM")
# Detect bench ref if available
BENCH_REF_RESOLVED=$(git -C "$BENCH_DIR" rev-parse --short HEAD 2>/dev/null || echo "n/a")

{
  echo "# zsh-bench"
  echo
  echo "| run  | total (ms) | ref | jobs |"
  echo "| --- | --- | --- | --- |"
  echo "| cold | ${COLD_MS:-n/a} | ${ZSH_BENCH_REF:-$BENCH_REF_RESOLVED} | ${JOBS:-n/a} |"
  echo "| warm | ${WARM_MS:-n/a} | ${ZSH_BENCH_REF:-$BENCH_REF_RESOLVED} | ${JOBS:-n/a} |"
  echo
  echo "## raw output (cold)"
  echo '```'
  cat "$OUT_TXT"
  echo '```'
  echo
  echo "## raw output (warm)"
  echo '```'
  cat "$OUT_TXT_WARM"
  echo '```'
} > "$OUT_MD"

echo "[bench] report generated at $OUT_MD"

# Optional: compinit profiling (top 5)
PROF_TXT="$ARTIFACT_DIR/zsh-prof.txt"
if command -v zsh >/dev/null; then
  ZDOTDIR="$ROOT/zsh" zsh -lc 'zmodload zsh/zprof; source "$ZDOTDIR/.zshrc"; zprof' >"$PROF_TXT" 2>&1 || true
  if [[ -s "$PROF_TXT" ]]; then
    {
      echo
      echo "## zprof (top 10)"
      echo '```'
      head -n 10 "$PROF_TXT"
      echo '```'
    } >> "$OUT_MD"
  else
    echo "[bench] zprof output empty; see $PROF_TXT for logs" >&2
  fi
fi
