{
  flake.nixosModules.workstationCli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        btop
        busybox
        curl
        dig
        eza
        fastfetch
        file
        htop
        inxi
        iw
        killall
        lshw
        man
        man-pages
        moreutils
        smartmontools
        stow
        talosctl
        textpieces
        tokei
        unzip
        vim
        wget
        wirelesstools
        yq
        zip
      ];
    };
}
