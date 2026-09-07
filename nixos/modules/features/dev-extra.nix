{
  flake.nixosModules.devExtra =
    { pkgs, ... }:
    {
      environment.systemPackages = (
        with pkgs;
        [
          ansible
          ansible-lint
          codespell
          openssl
          nfs-utils
          arp-scan
          gitleaks
          prisma_7
          prisma-engines_7
          k6
          python312Packages.distlib
          python312Packages.libtmux
          stack
          terraform
          playwright-driver
          rumdl
          nil
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

      environment.variables.PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines_7}/bin/schema-engine";
    };
}
