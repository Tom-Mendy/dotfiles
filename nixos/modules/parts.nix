{
  config = {
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem =
      { pkgs, lib, ... }:
      {
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
