{ inputs, ... }:
{
  flake.nixosModules.workstationDevApps =
    {
      pkgs,
      unstable,
      ...
    }:
    {
      services.tailscale.enable = true;
      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
        unstable.vscode
        unstable.herdr
        unstable.zed-editor
        unstable.pangolin-cli
      ];
    };
}
