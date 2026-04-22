{ self, inputs, ... }: {
flake.nixosModules.zephyrusG14Hardware = { config , lib, pkgs, modulesPath, ...}:{
  imports = [ ( modulesPath + "/installer/scan/not-detected.nix" ) ];

  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3fac1dae-5473-4800-820b-03bca8584491";
      fsType = "ext4";
    };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
};
}
