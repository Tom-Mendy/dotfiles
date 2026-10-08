{
  flake.nixosModules.devExtra =
    { pkgs, unstable, ... }:
    {
      environment.systemPackages = (
        with pkgs;
        [
          codespell
          openssl
          nfs-utils
          arp-scan
          gitleaks
          k6
          python3Packages.distlib
          python3Packages.libtmux
          terraform
          forgejo-cli
          rumdl
          unstable.devenv
          nil
          sqlite
          wrkflw
          nixd
        ]
      );
    };
}
