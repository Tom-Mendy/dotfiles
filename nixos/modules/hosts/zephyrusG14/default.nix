{ self, inputs, ... }: {
  flake.nixosConfigurations.zephyrusG14 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.zephyrusG14Configuration
    ];
  };
}
