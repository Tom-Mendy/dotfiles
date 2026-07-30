{
  flake.nixosModules.t3Code =
    { pkgs, ... }:
    let
      pname = "t3-code";
      version = "0.0.31";

      src = pkgs.fetchurl {
        url = "https://github.com/pingdotgg/t3code/releases/download/v${version}/T3-Code-${version}-x86_64.AppImage";
        hash = "sha256-AqTkoSKeQwmql3L9F5SbD1XyqeFyqe11ciq9Tp04Zyw=";
      };

      appimageContents = pkgs.appimageTools.extractType2 {
        inherit pname version src;
      };

      t3-code = pkgs.appimageTools.wrapType2 {
        inherit pname version src;

        extraInstallCommands = ''
          install -Dm444 ${appimageContents}/t3code.desktop $out/share/applications/t3code.desktop
          substituteInPlace $out/share/applications/t3code.desktop \
            --replace-fail "Exec=AppRun" "Exec=t3-code"
          cp -r ${appimageContents}/usr/share/icons $out/share/
        '';
      };
    in
    {
      environment.systemPackages = [ t3-code ];
    };
}
