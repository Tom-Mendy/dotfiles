{
  flake.nixosModules.kdePlasma =
    { pkgs, lib, ... }:
    {
      services.displayManager.sddm.enable = true;
      services.desktopManager.plasma6.enable = true;

      environment.etc."xdg/kdeglobals".text = ''
        [General]
        TerminalApplication=ghostty
        TerminalService=com.mitchellh.ghostty.desktop
      '';
      environment.etc."xdg/klipperrc".text = ''
        [General]
        KeepClipboardContents=false
        MaxClipItems=1
        IgnoreSelection=true
        SelectionTextOnly=true
        IgnoreImages=true
        URLGrabberEnabled=false
      '';
      environment.etc."xdg/autostart/cliphist-text.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=cliphist text watcher
        Exec=${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} -max-items 750 store
        OnlyShowIn=KDE;
        X-KDE-autostart-after=panel
      '';
      environment.etc."xdg/autostart/cliphist-image.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=cliphist image watcher
        Exec=${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} -max-items 750 store
        OnlyShowIn=KDE;
        X-KDE-autostart-after=panel
      '';

      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "com.mitchellh.ghostty.desktop" ];
          KDE = [ "com.mitchellh.ghostty.desktop" ];
        };
      };

      environment.systemPackages = [
        pkgs.kdePackages.dolphin
        pkgs.cliphist
        pkgs.wl-clipboard
      ];
    };
}
