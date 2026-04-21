{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../../modules
  ];

  networking.hostName = "dev-nix";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  my.environment = {
    enable = true;
    profile = "full";
    user = "tmendy";
  };

  my.desktop = {
    enable = true;
    type = "hyprland";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
