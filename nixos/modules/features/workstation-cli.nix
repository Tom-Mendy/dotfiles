{
  flake.nixosModules.workstationCli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        (btop.override {
          cudaSupport = true;
          rocmSupport = true;
        })
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
        rocmPackages.rocm-smi
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
