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
        antigravity-acp
        grok-build
        claude-code
        opencode
        t3code
      ];
    };
}
