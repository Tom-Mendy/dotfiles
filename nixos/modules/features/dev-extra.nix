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
          nixd
        ]
      );

      environment.variables.PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines_7}/bin/schema-engine";
    };
}
