{ inputs, ... }:
{
  config = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem =
      { lib, system, ... }:
      let
        # Single shared instance for everything under perSystem (wrappers,
        # devShell, formatter): allowUnfree on, so no module needs its own
        # `import nixpkgs` (each extra instance adds a full nixpkgs
        # evaluation to EVERY nix command). Replaces flake-parts' default
        # legacyPackages instance; free packages resolve to identical paths.
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        _module.args.pkgs = pkgs;

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            git
            shellcheck
            zsh
          ];
        };

        formatter = pkgs.writeShellApplication {
          name = "dotfiles-nixfmt";
          text = ''
            if [ "$#" -gt 0 ]; then
              exec ${lib.getExe pkgs.nixfmt} "$@"
            fi

            ${lib.getExe pkgs.fd} \
              --extension nix \
              --type f \
              --hidden \
              --exclude .git \
              --exec ${lib.getExe pkgs.nixfmt} {}
          '';
        };
      };
  };
}
