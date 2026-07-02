{
  flake.nixosModules.containers =
    { lib, pkgs, ... }:
    {
      virtualisation.containers.enable = true;
      virtualisation.docker.enable = true;
      virtualisation.podman = {
        enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.tmendy.extraGroups = lib.mkAfter [ "docker" ];

      environment.systemPackages = with pkgs; [
        cri-tools
        dive
        docker-compose
        lazydocker
        hadolint
        podman-compose
        podman-tui
        helm
        trivy
        kubectl
      ];
    };
}
