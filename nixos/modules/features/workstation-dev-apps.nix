{ inputs, ... }:
{
  flake.nixosModules.workstationDevApps =
    {
      pkgs,
      unstable,
      ...
    }:
    {
      environment.sessionVariables.DEVCONTAINER_ENGINE = "podman";

      environment.systemPackages = [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
        unstable.codex
        unstable.opencode
        unstable.vscode
        unstable.herdr
        unstable.t3code
        unstable.zed-editor
        unstable.pangolin-cli
      ];
    };
}
