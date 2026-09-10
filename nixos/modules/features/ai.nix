{
  flake.nixosModules.ai =
    {
      unstable,
      ...
    }:
    {
      environment.systemPackages = [
        unstable.codex
        unstable.antigravity-cli
        unstable.opencode
        unstable.t3code
      ];
    };
}
