{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git curl jq
  ];
}
