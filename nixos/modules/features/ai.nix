{
  flake.nixosModules.ai =
    {
      unstable,
      ...
    }:
    {
      environment.systemPackages = with unstable; [
        codex
        antigravity-cli
        claude-code
        opencode
        t3code
      ];
    };
}
