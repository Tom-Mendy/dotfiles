{
  description = "Modular NixOS configuration (minimal/full environment + desktop module)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.dev-nix = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/dev-nix/configuration.nix ];
      };

      packages.${system}.config-check = pkgs.writeShellApplication {
        name = "config-check";
        runtimeInputs = [ pkgs.nix ];
        text = ''
          echo "Checking nixosConfiguration evaluation..."
          nix eval .#nixosConfigurations.dev-nix.config.my.environment.profile
          nix eval .#nixosConfigurations.dev-nix.config.my.desktop.type
          echo "OK"
        '';
      };

      apps.${system}.config-check = {
        type = "app";
        program = "${self.packages.${system}.config-check}/bin/config-check";
      };
    };
}
