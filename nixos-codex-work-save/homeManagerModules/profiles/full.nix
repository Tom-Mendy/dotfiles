{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lazygit
    docker-compose
    kubectl
    nodejs_22
    python3
    go
    rustup
  ];
}
