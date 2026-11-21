{
  flake.nixosModules.workstationDesktop =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        alsa-lib
        atk
        brightnessctl
        bruno
        cpu-x
        libreoffice
        localsend
        ntfs3g
        xmind
        arduino-ide
        policycoreutils
        qalculate-gtk
        speedtest
        # veracrypt
        gparted
        wl-clipboard
      ];
    };
}
