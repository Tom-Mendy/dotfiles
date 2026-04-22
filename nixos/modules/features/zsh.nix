{ self, inputs, ... }:
let
  mainModule =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      options = {
        dynamicMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Use an impure zsh config directory for fast local edits.
          '';
        };

        zdotdirPath = lib.mkOption {
          type = wlib.types.stringable;
          default = inputs.zsh-config.outPath;
        };

        dynamicZdotdirPath = lib.mkOption {
          type = wlib.types.stringable;
          default = "~/dotfiles/zsh";
        };
      };

      config = {
        zdotdir = if config.dynamicMode then config.dynamicZdotdirPath else config.zdotdirPath;
        hmSessionVariables = null;

        extraPackages = with pkgs; [
          atuin
          bat
          direnv
          eza
          fd
          fzf
          git
          jq
          kubectl
          ripgrep
          safe-rm
          sesh
          zoxide
        ];

        zshrc.content = ''
          [[ -f ${config.zdotdir}/.p10k.zsh ]] && source ${config.zdotdir}/.p10k.zsh
        '';
      };
    };
in
{
  flake.nixosModules.zsh =
    { pkgs, ... }:
    let
      zshPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.zsh;
    in
    {
      programs.zsh.enable = true;
      environment.pathsToLink = [ "/share/zsh" ];
      environment.shells = [ zshPackage ];
      environment.systemPackages = [ zshPackage ];
      users.users.tmendy.shell = zshPackage;
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.zsh = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        imports = [
          mainModule
        ];
      };

      packages.zshDynamic = inputs.wrapper-modules.wrappers.zsh.wrap {
        inherit pkgs;
        dynamicMode = true;
        imports = [
          mainModule
        ];
      };
    };
}
