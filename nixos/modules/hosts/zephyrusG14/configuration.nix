{ self, ... }:
{
  flake.nixosModules.zephyrusG14Configuration =
    { pkgs, ... }:
    {
      imports = [
        self.nixosModules.common
        self.nixosModules.containers
        self.nixosModules.devCore
        self.nixosModules.devExtra
        self.nixosModules.gaming
        self.nixosModules.howdy
        self.nixosModules.rbw
        self.nixosModules.zephyrusG14Hardware
        self.nixosModules.neovim
        self.nixosModules.niri
        self.nixosModules.nymVpn
        self.nixosModules.rog
        self.nixosModules.virtualisation
        self.nixosModules.whisperDictation
        self.nixosModules.workstation
        self.nixosModules.zsh
        self.nixosModules.synologySftp
      ];

      system.autoUpgrade = {
        enable = true;
        flake = "/home/tmendy/dotfiles/nixos#zephyrusG14";
        dates = "Sun *-*-* 04:40:00";
        persistent = true;
        allowReboot = false;
        upgrade = false;
        flags = [
          "--update-input"
          "nixpkgs"
          "--update-input"
          "nixpkgs-unstable"
          "--update-input"
          "flake-parts"
          "--update-input"
          "import-tree"
          "--update-input"
          "zen-browser"
          "--update-input"
          "helium"
          "--update-input"
          "wrapper-modules"
          "--commit-lock-file"
        ];
      };

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages_7_1;
        resumeDevice = "/dev/mapper/luks-fff3f818-7e03-48e0-ae07-a149b29524ec";
        kernelParams = [ "resume_offset=84489648" ];
        kernel.sysctl = {
          "vm.swappiness" = 10;
          "vm.page-cluster" = 0;
        };
      };

      systemd.services.rtsx-pci-sleep = {
        description = "Unload Realtek card reader before sleep";
        requiredBy = [ "sleep.target" ];
        before = [ "sleep.target" ];
        unitConfig.StopWhenUnneeded = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.kmod}/bin/modprobe -r rtsx_pci_sdmmc rtsx_pci";
          ExecStop = "${pkgs.kmod}/bin/modprobe rtsx_pci_sdmmc";
        };
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
      };

      networking.hostName = "zephyrusG14";

      services.openssh.enable = true;
      users.users.tmendy.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGndRLmp+mIsp+K1QP8uutK+u27wdkknhRaNusnb3Rn8"
      ];

      hardware.graphics.enable = true;
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0294", RUN+="${pkgs.alsa-utils}/bin/amixer -q -c S sset Mic playback mute"
      '';
      services.xserver.videoDrivers = [
        "amdgpu"
        "nvidia"
      ];
      hardware.nvidia = {
        open = true;
        powerManagement.enable = true;
        prime = {
          nvidiaBusId = "PCI:100@0:0:0";
          amdgpuBusId = "PCI:101@0:0:0";
        };
      };

      services.howdy.settings.video.device_path = "/dev/video2";

      system.stateVersion = "26.05";
    };
}
