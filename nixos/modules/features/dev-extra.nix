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
          playwright-driver
          rumdl
          unstable.devenv
          nil
          sqlite
          wrkflw
          nixd
        ]
      );

      # Use the Nix-patched browsers instead of Playwright's downloaded
      # binaries, which cannot resolve shared libraries on NixOS.
      environment.variables = {
        PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
      };
    };
}
