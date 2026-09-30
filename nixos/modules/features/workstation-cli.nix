{
  flake.nixosModules.workstationCli =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # NOTE: do NOT re-enable cudaSupport/rocmSupport here without a
        # personal binary cache: any .override changes the derivation hash,
        # so the official cache can no longer be used and btop (+ its CUDA
        # closure) gets rebuilt locally on every bump.
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
        rocmPackages.rocm-smi
        smartmontools
        stow
        talosctl
        yt-dlp
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
