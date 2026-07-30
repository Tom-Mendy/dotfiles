{
  flake.nixosModules.containers =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    {
      virtualisation.containers.enable = true;
      virtualisation.docker.enable = true;
      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.${username}.extraGroups = lib.mkAfter [ "docker" ];

      environment.systemPackages = with pkgs; [
        cri-tools
        dive
        docker-compose
        lazydocker
        hadolint
        devcontainer
        podman-compose
        podman-tui
        kubernetes-helm
        trivy
        kubectl
      ];
    };
}
