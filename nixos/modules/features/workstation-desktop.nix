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
        networkmanagerapplet
        ntfs3g
        policycoreutils
        proton-vpn-cli
        qalculate-gtk
        rustdesk
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
