{
  flake.nixosModules.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = false;
        dedicatedServer.openFirewall = false;
        localNetworkGameTransfers.openFirewall = true;
        extest.enable = false;
      };
      programs.gamescope.enable = true;

      environment.sessionVariables.STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";

      environment.systemPackages = with pkgs; [
        heroic
        protonup-qt
      ];
    };
}
