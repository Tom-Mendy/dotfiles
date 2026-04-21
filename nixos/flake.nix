{
  description = "dev-nix config (vimjoyer-style layout: hosts + nixosModules + homeManagerModules)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hostName; };
        modules = [
          home-manager.nixosModules.home-manager
          ./hosts/common
          ./hosts/${hostName}
        ];
      };
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.dev-nix = mkHost "dev-nix";

      nixosModules = import ./nixosModules;
      homeManagerModules = import ./homeManagerModules;

      packages.${system}.check-dev-nix = pkgs.writeShellApplication {
        name = "check-dev-nix";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          nix eval .#nixosConfigurations.dev-nix.config.networking.hostName
          nix eval .#nixosConfigurations.dev-nix.config.my.environment.profile
          nix eval .#nixosConfigurations.dev-nix.config.my.desktop.profile
        '';
      };

      apps.${system}.check-dev-nix = {
        type = "app";
        program = "${self.packages.${system}.check-dev-nix}/bin/check-dev-nix";
      };
    };
}
