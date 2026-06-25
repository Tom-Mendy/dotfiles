{
  flake.nixosModules.kdePlasma =
    { pkgs, ... }:
    {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment.systemPackages = with pkgs.kdePackages; [
        dolphin
        kate
      ];
    };
}
