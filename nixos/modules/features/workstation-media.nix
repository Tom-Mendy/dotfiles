{
  flake.nixosModules.workstationMedia =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        dav1d
        ffmpeg
        supersonic
        vlc
      ];
    };
}
