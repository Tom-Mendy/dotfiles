{
  flake.nixosModules.ai =
    {
      unstable,
      pkgs,
      ...
    }:
    let
      # Workaround for t3code 0.0.45: node-pty cannot load libstdc++.so.6,
      # so the backend keeps restarting and the desktop window never opens.
      # Remove this override once the nixpkgs package supplies that library
      # via its runtime search path. Verify that unmodified unstable.t3code
      # opens a window with LD_LIBRARY_PATH unset, then use unstable.t3code
      # directly in systemPackages and remove the pkgs argument above.
      t3code = unstable.t3code.overrideAttrs (old: {
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
        unstable.codex
        unstable.antigravity-cli
        unstable.opencode
        t3code
      ];
    };
}
