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
        policycoreutils
        qalculate-gtk
        speedtest
        veracrypt
        volumeicon
        xclip
        xdpyinfo
        xhost
        xkill
      ];
    };
}
