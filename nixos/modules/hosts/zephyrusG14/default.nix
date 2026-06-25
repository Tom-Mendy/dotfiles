{ self, inputs, ... }:
let
  system = "x86_64-linux";
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "electron-39.8.10"
      ];
    };
  };
in
{
  flake.nixosConfigurations.zephyrusG14 = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit unstable;
    };
    modules = [
      self.nixosModules.zephyrusG14Configuration
    ];
  };
}
