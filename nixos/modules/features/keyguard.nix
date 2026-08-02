{
  flake.nixosModules.rbw =
    { pkgs, ... }:
    {
      environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/rbw/ssh-agent-socket";

      environment.systemPackages = with pkgs; [
        pinentry-gnome3
        rbw
      ];
    };
}
