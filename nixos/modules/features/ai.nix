{
  flake.nixosModules.ai =
    {
      unstable,
      ...
    }:
    {
      environment.systemPackages = with unstable; [
        rtk
        codex
        antigravity-cli
        claude-code
        opencode
        t3code
      ];
    };
}
