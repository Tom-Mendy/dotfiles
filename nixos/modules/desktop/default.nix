{ config, lib, pkgs, ... }:

let
  cfg = config.my.desktop;
in
{
  options.my.desktop = {
    enable = lib.mkEnableOption "desktop stack";
    type = lib.mkOption {
      type = lib.types.enum [ "gnome" "hyprland" "none" ];
      default = "none";
      description = "Desktop profile to enable.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable = cfg.type != "none";
    services.displayManager.defaultSession = lib.mkIf (cfg.type == "hyprland") "hyprland";

    services.xserver.displayManager.gdm.enable = cfg.type == "gnome";
    services.xserver.desktopManager.gnome.enable = cfg.type == "gnome";

    programs.hyprland.enable = cfg.type == "hyprland";
    programs.hyprland.xwayland.enable = cfg.type == "hyprland";

    environment.systemPackages = with pkgs;
      lib.optionals (cfg.type == "hyprland") [ waybar wofi grim slurp wl-clipboard ];
  };
}
