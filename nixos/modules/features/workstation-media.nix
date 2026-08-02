{
  flake.nixosModules.workstationMedia =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        amberol
        dav1d
        ffmpeg
        termusic
        supersonic
        vlc
      ];

      systemd.user.services.termusic-server = {
        description = "Termusic music server";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.termusic}/bin/termusic-server";
          Restart = "always";
          RestartSec = "1s";
        };
      };
    };
}
