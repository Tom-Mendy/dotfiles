{
  flake.nixosModules.workstationMedia =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        dav1d
        ffmpeg
        termusic
        vlc
        mpv
      ];

      systemd.user.services.termusic-server = {
        description = "Termusic music server";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.termusic}/bin/termusic-server";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
