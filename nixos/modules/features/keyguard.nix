{
  flake.nixosModules.keyguard =
    { lib, pkgs, ... }:
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
          nativeBuildInputs = [
            pkgs.autoPatchelfHook
            pkgs.makeWrapper
          ];
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
            dbus
          ];

          installPhase = "cp -r . $out; chmod +x $out/bin/Keyguard";
          postFixup = ''
            mkdir -p $out/libexec
            mv $out/bin/Keyguard $out/libexec/Keyguard
            makeWrapper $out/libexec/Keyguard $out/bin/Keyguard \
              --set SKIKO_RENDER_API SOFTWARE_FAST \
              --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.dbus ]}"
          '';
        })
      ];

      environment.etc."xdg/autostart/keyguard.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Keyguard
        Exec=Keyguard
        OnlyShowIn=KDE;
        X-KDE-autostart-after=panel
      '';
    };
}
