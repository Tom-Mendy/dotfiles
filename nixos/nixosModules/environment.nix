{ config, lib, pkgs, ... }:
let
  cfg = config.my.environment;
in
{
  options.my.environment = {
    enable = lib.mkEnableOption "system environment";
    profile = lib.mkOption {
      type = lib.types.enum [ "minimal" "full" ];
      default = "minimal";
      description = "Minimal or full development environment.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    users.defaultUserShell = pkgs.zsh;

    environment.systemPackages = with pkgs;
      [
        git curl wget jq
        eza fd ripgrep bat fzf zoxide
        tmux neovim
      ]
      ++ lib.optionals (cfg.profile == "full") [
        gcc gnumake cmake
        nodejs_22 python3 go rustup
        docker-compose kubectl
      ];
  };
}
