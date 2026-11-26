{
  flake.nixosModules.workstationDesktop =
    { pkgs, unstable, ... }:
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
        unstable.ladybird
        qalculate-gtk
        speedtest
        # veracrypt
        gparted
        wl-clipboard
      ];
    };
}
