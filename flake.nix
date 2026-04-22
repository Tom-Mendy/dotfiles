{
  description = "Tom Mendy dotfiles dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      formatter = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.writeShellApplication {
          name = "dotfiles-nixfmt";
          text = ''
            if [ "$#" -gt 0 ]; then
              exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt "$@"
            fi

            ${pkgs.fd}/bin/fd \
              --extension nix \
              --type f \
              --hidden \
              --exclude .git \
              --exclude _save-config \
              --exclude nixos-codex-work-save \
              --exec ${pkgs.nixfmt-rfc-style}/bin/nixfmt {}
          '';
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
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
        }
      );
    };
}
