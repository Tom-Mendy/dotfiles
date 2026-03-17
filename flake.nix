{
  description = "Tom Mendy dotfiles dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in {
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              zsh
              fzf
              zoxide
              eza
              bat
              git
              kubectl
              docker-client
              shellcheck
              curl
              jq
            ];
            shellHook = ''
              echo "Loaded nix devShell with zsh/fzf/zoxide/eza/bat/git/kubectl/docker-client"
              export PATH=$PATH:${pkgs.zsh}/bin
            '';
          };
        });
    };
}
