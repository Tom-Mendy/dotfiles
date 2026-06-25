{ self, inputs, ... }:
{
  flake.nixosModules.zephyrusG14Hardware =
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/luks-fff3f818-7e03-48e0-ae07-a149b29524ec";
      fsType = "btrfs";
    };

  boot.initrd.luks.devices."luks-fff3f818-7e03-48e0-ae07-a149b29524ec".device = "/dev/disk/by-uuid/fff3f818-7e03-48e0-ae07-a149b29524ec";

  fileSystems."/home" =
    { device = "/dev/mapper/luks-fff3f818-7e03-48e0-ae07-a149b29524ec";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/mapper/luks-fff3f818-7e03-48e0-ae07-a149b29524ec";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/8864-F380";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [ { device = "/dev/mapper/luks-e9e0e2e3-aedc-447b-b7f8-22d88b5a9138"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
};
}
