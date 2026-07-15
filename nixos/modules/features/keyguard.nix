{
  flake.nixosModules.keyguard =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "keyguard";
          version = "2.14.2";

          src = pkgs.fetchurl {
            url = "https://github.com/AChep/keyguard-app/releases/download/r20260616/Keyguard-2.14.2-linux-x86_64.tar.gz";
            hash = "sha256-53ZByjMU+0xB1BNY5ZyArhmmUM1IqgGYb5nYwuG+b3g=";
          };

          sourceRoot = "Keyguard";
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];
          buildInputs = with pkgs; [
            fontconfig
            libxinerama
            libxrandr
            libxtst
            file
            gtk3
            glib
            cups
            lcms2
            alsa-lib
            libglvnd
          ];

          installPhase = "cp -r . $out; chmod +x $out/bin/Keyguard";
        })
      ];
    };
}
