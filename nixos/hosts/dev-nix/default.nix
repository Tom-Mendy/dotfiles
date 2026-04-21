{ hostName, ... }:
{
  networking.hostName = hostName;

  my.environment = {
    enable = true;
    profile = "full";
  };

  my.desktop = {
    enable = true;
    profile = "hyprland";
  };

  system.stateVersion = "24.11";
}
