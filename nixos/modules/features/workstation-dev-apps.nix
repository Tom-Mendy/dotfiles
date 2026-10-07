{ self, inputs, ... }:
{
  flake.nixosModules.workstationDevApps =
    {
      pkgs,
      unstable,
      ...
    }:
    {
      # services.tailscale.enable = true;
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
        unstable.vscode
        self.packages.${pkgs.stdenv.hostPlatform.system}.herdr-bin
        unstable.zed-editor
        unstable.pangolin-cli
      ];
    };

  # herdr from nixpkgs is buildRustPackage (full local Rust compile, see
  # `building herdr-0.9.1 ... Compiling toml`). Upstream ships a static
  # Linux x86_64 binary, so install it directly: download + copy instead
  # of compiling hundreds of crates.
  # To bump: update `version`, then run
  #   nix store prefetch-file --json "https://github.com/herdrdev/herdr/releases/download/v<version>/herdr-linux-x86_64"
  # and paste the new `hash`.
  #
  # NOTE: a similar zed-bin experiment (upstream zed tarball instead of
  # nixpkgs' Rust build) was reverted 2026-09-30: the binary died instantly
  # and silently on this machine (no log, no coredump, zombie launcher),
  # even with the nixpkgs-identical Vulkan/GL/Wayland RPATH. See git
  # history of this file for the attempt.
  perSystem =
    { pkgs, ... }:
    {
      packages.herdr-bin = pkgs.stdenvNoCC.mkDerivation rec {
        pname = "herdr";
        version = "0.9.1";
        src = pkgs.fetchurl {
          url = "https://github.com/herdrdev/herdr/releases/download/v${version}/herdr-linux-x86_64";
          hash = "sha256-KgL+0WvrZR7wBuHUPwSPZSyk3FitBTzS1ERQVj1cVLc=";
        };
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 "$src" "$out/bin/herdr"
          runHook postInstall
        '';
        meta = with pkgs.lib; {
          description = "Terminal workspace manager for AI coding agents";
          homepage = "https://herdr.dev";
          license = licenses.asl20;
          platforms = [ "x86_64-linux" ];
          mainProgram = "herdr";
        };
      };
    };
}
