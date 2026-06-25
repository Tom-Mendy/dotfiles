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
          erlang
          ghc
          gleam
          ghostscript
          gnucobol
          k6
          python312Packages.distlib
          python312Packages.libtmux
          rebar3
          stack
          terraform
          tetex
          texliveFull
          android-tools
        ])
        ++ [
          unstable.android-studio
        ];
    };
}
