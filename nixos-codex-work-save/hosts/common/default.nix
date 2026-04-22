{ inputs, lib, config, ... }:
{
  imports = [
    inputs.self.nixosModules.environment
    inputs.self.nixosModules.desktop
  ];

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  users.users.tmendy = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "docker" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.tmendy = { ... }: {
      imports = [
        inputs.self.homeManagerModules.zsh
        inputs.self.homeManagerModules.neovim
        inputs.self.homeManagerModules.minimal
        (lib.mkIf (config.my.environment.profile == "full") inputs.self.homeManagerModules.full)
      ];

      home.username = "tmendy";
      home.homeDirectory = "/home/tmendy";
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
