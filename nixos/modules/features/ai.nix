{
  flake.nixosModules.ai =
    {
      unstable,
      pkgs,
      ...
    }:
    let
      # Temporary fix for the node_modules hash shipped with opencode 2.2.5.
      # Remove once the pinned nixpkgs package builds without this override.
      opencode = unstable.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
        };
      });

      # Workaround for codex 0.167.0: its vendored sys crates (zstd-sys,
      # aws-lc-sys, onig-sys, libsqlite3-sys) probe pkg-config, but the nixpkgs
      # package omits those libraries from buildInputs. Mirrors the upstream fix
      # in nixpkgs commit 16b463698a ("codex: fix build with sys libs").
      # Remove once the pinned nixpkgs package includes those build inputs.
      codex = unstable.codex.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [
          unstable.aws-lc
          unstable.oniguruma
          unstable.sqlite
          unstable.zstd
        ];
      });

      # Workaround for t3code 0.0.45: node-pty cannot load libstdc++.so.6,
      # so the backend keeps restarting and the desktop window never opens.
      # Remove this override once the nixpkgs package supplies that library
      # via its runtime search path. Verify that unmodified unstable.t3code
      # opens a window with LD_LIBRARY_PATH unset, then use unstable.t3code
      # directly in systemPackages and remove the pkgs argument above.
      #
      # The codex override is also injected here because t3code bundles codex
      # itself (enableCodex defaults to true) and would otherwise pull in the
      # broken unstable.codex.
      t3code = (unstable.t3code.override { codex = codex; }).overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        postFixup = (old.postFixup or "") + ''
          wrapProgram "$out/bin/t3code-desktop" \
            --prefix LD_LIBRARY_PATH : "${unstable.stdenv.cc.cc.lib}/lib"
        '';
      });
    in
    {
      environment.systemPackages = [
        unstable.rtk
        codex
        unstable.antigravity-cli
        unstable.claude-code
        opencode
        t3code
      ];
    };
}
