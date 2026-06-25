{
  flake.nixosModules.devExtra =
    { pkgs, unstable, ... }:
    {
      environment.systemPackages =
        (with pkgs; [
          ansible
          ansible-lint
          codespell
          cypress
          k6
          python312Packages.distlib
          python312Packages.libtmux
          stack
          terraform
        ]);
    };
}
