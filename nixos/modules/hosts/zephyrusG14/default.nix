{ self, inputs, ... }:
let
  system = "x86_64-linux";
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
in
{
  flake.nixosConfigurations.zephyrusG14 = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit unstable;
      username = "tmendy";
    };
    modules = [
      (inputs.nixpkgs-unstable + "/nixos/modules/services/hardware/cardwired.nix")
      self.nixosModules.zephyrusG14Configuration
    ];
  };
}
