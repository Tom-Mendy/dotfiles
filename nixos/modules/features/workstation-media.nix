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
    };
}
