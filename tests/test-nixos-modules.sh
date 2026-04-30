#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if command -v git > /dev/null 2>&1; then
  git config --global --add safe.directory "$PWD" 2> /dev/null || true
fi

nix_cmd=(
  nix
  --extra-experimental-features nix-command
  --extra-experimental-features flakes
)

system="$("${nix_cmd[@]}" eval --impure --expr 'builtins.currentSystem' --raw)"

echo "checking ./nixos#zsh package output"
package_name="$("${nix_cmd[@]}" eval "./nixos#packages.${system}.zsh.name" --raw)"
case "$package_name" in
  zsh-*) ;;
  *)
    echo "expected ./nixos#zsh to evaluate to a zsh package, got: $package_name" >&2
    exit 1
    ;;
esac

echo "checking ./nixos#zsh dry build"
"${nix_cmd[@]}" build ./nixos#zsh --dry-run

echo "checking ./nixos#zsh derivation references"
drv_json="$(mktemp)"
trap 'rm -f "$drv_json"' EXIT
"${nix_cmd[@]}" derivation show ./nixos#zsh > "$drv_json"

if grep -Eiq 'neovim|noctalia|niri' "$drv_json"; then
  echo "./nixos#zsh derivation should not reference neovim, noctalia, or niri" >&2
  grep -Ein 'neovim|noctalia|niri' "$drv_json" >&2
  exit 1
fi

if ! grep -q 'export EDITOR=vim' "$drv_json"; then
  echo "./nixos#zsh should export EDITOR=vim without a Nix store vim path" >&2
  exit 1
fi

if ! grep -q '/nixos/../zsh/.p10k.zsh' "$drv_json"; then
  echo "./nixos#zsh should embed the Powerlevel10k config from zsh/.p10k.zsh" >&2
  exit 1
fi

if [[ ${SKIP_ZSH_RUNTIME_TEST:-0} != "1" ]]; then
  echo "checking wrapped zsh EDITOR at runtime"
  "${nix_cmd[@]}" run ./nixos#zsh -- -c '[[ "$EDITOR" = vim ]]'
fi

echo "checking nixosModules.zsh evaluation"
module_enabled="$(
  "${nix_cmd[@]}" eval --impure --raw --expr '
    let
      flake = builtins.getFlake (toString ./nixos);
      system = builtins.currentSystem;
      evaluated = flake.inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          flake.nixosModules.zsh
          ({ ... }: { users.users.tmendy.isNormalUser = true; })
        ];
      };
    in
      if evaluated.config.programs.zsh.enable then "true" else "false"
  '
)"

if [[ $module_enabled != "true" ]]; then
  echo "expected nixosModules.zsh to enable programs.zsh" >&2
  exit 1
fi

echo "nixos zsh module tests passed"
