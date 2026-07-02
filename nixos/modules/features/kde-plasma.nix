{
  flake.nixosModules.kdePlasma =
    { pkgs, ... }:
    {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment.etc."xdg/kdeglobals".text = ''
        [General]
        TerminalApplication=ghostty
        TerminalService=com.mitchellh.ghostty.desktop
      '';

      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "com.mitchellh.ghostty.desktop" ];
          KDE = [ "com.mitchellh.ghostty.desktop" ];
        };
      };

      environment.systemPackages = with pkgs.kdePackages; [
        dolphin
      ];
    };
}
