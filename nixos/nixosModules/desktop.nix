{ config, lib, pkgs, ... }:
let
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = lib.mkEnableOption "desktop environment";
    profile = lib.mkOption {
      type = lib.types.enum [ "none" "gnome" "hyprland" ];
      default = "none";
      description = "Desktop profile.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = cfg.profile != "none";
    services.xserver.displayManager.gdm.enable = cfg.profile == "gnome";
    services.xserver.desktopManager.gnome.enable = cfg.profile == "gnome";

    programs.hyprland.enable = cfg.profile == "hyprland";
    programs.hyprland.xwayland.enable = cfg.profile == "hyprland";
    services.displayManager.defaultSession = lib.mkIf (cfg.profile == "hyprland") "hyprland";

    environment.systemPackages = with pkgs;
      lib.optionals (cfg.profile == "hyprland") [ waybar wofi grim slurp wl-clipboard ];
  };
}
