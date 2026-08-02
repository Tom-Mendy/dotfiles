{
  flake.nixosModules.containers =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    {
      virtualisation = {
        containers.enable = true;
        docker.enable = false;
        podman = {
          enable = true;
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };
      };

      users.users.${username}.extraGroups = lib.mkAfter [
        "docker"
        "podman"
      ];

      environment.systemPackages = with pkgs; [
        cri-tools
        dive
        docker-compose
        lazydocker
        hadolint
        devcontainer
        podman-tui
        kubernetes-helm
        trivy
        kubectl
      ];
    };
}
