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
        policycoreutils
        qalculate-gtk
        speedtest
        coder
        unstable.devenv
        veracrypt
        gparted
        wl-clipboard
      ];
    };
}
