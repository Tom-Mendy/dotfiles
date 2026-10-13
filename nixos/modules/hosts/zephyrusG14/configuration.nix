{ self, ... }:
{
  flake.nixosModules.zephyrusG14Configuration =
    {
      pkgs,
      unstable,
      username,
      ...
    }:
    {
      imports = [
        self.nixosModules.ai
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
        # self.nixosModules.virtualisation
        self.nixosModules.whisperDictation
        self.nixosModules.workstation
        self.nixosModules.zsh
        self.nixosModules.synologySftp
      ];

      system.autoUpgrade = {
        enable = true;
        flake = "/home/${username}/dotfiles/nixos#zephyrusG14";
        dates = "Sun *-*-* 04:40:00";
        persistent = true;
        allowReboot = false;
        upgrade = false;
        # NOTE: intentionally no --update-input flags. Bumping nixpkgs (and
        # especially nixpkgs-unstable) on every Sunday timer moves the lock to
        # commits Hydra hasn't finished building yet, which turns the next
        # rebuild into a local compile storm. Update inputs manually with
        # `nix flake update` when you actually want new versions.
        flags = [ ];
      };

      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        # Default release kernel (currently 6.18.x), NOT linuxPackages_latest:
        # Hydra fully builds it including the NVIDIA module, so rebuilds stay
        # download-only. _latest moves constantly and forces local compiles of
        # the kernel modules + initrd on every bump. If hardware ever needs a
        # newer kernel, switch this AND hardware.nvidia.package together.
        kernelPackages = pkgs.linuxPackages;
        kernel.sysctl = {
          "vm.swappiness" = 0;
          "vm.page-cluster" = 0;
          # Bound writeback batches during large Steam updates on Btrfs.
          # Percentage defaults allow several GiB of pending writes on 32 GiB RAM.
          "vm.dirty_background_bytes" = 64 * 1024 * 1024;
          "vm.dirty_bytes" = 256 * 1024 * 1024;
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

      # The dual-boot layout intentionally has no persistent swap device.
      # Keep hibernation unavailable until a dedicated swapfile/partition and
      # matching resume configuration are added.
      systemd.sleep.settings.Sleep.AllowHibernation = false;

      networking.hostName = "zephyrusG14";
      networking.firewall.allowedTCPPorts = [ 5037 ];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
        };
      };
      users.users.${username}.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGndRLmp+mIsp+K1QP8uutK+u27wdkknhRaNusnb3Rn8"
      ];

      hardware.graphics.enable = true;
      services.udev.extraRules = ''
        # Kyber regulates queue depth to target low read/write latency under load.
        ACTION=="add|change", SUBSYSTEM=="block", KERNEL=="nvme[0-9]*n[0-9]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="kyber"
        ACTION=="add", SUBSYSTEM=="sound", KERNEL=="controlC*", ATTRS{idVendor}=="03f0", ATTRS{idProduct}=="0294", RUN+="${pkgs.alsa-utils}/bin/amixer -q -c S sset Mic playback mute"
      '';
      services.xserver.videoDrivers = [
        "amdgpu"
        "nvidia"
      ];
      hardware.nvidia = {
        # Keep kernel AND driver from the same nixpkgs: Hydra builds and
        # caches that exact combo. Mixing a stable kernel with an unstable
        # driver creates a custom kernel-module derivation that must be
        # built locally. If the stable production driver ever lags behind
        # what your RTX 5070 needs, switch BOTH together instead:
        #   boot.kernelPackages = pkgs.linuxPackages_latest;
        #   hardware.nvidia.package = pkgs.linuxPackages_latest.nvidiaPackages.production;
        package = pkgs.linuxPackages.nvidiaPackages.production;
        open = true;
        powerManagement.enable = true;
        prime = {
          nvidiaBusId = "PCI:100@0:0:0";
          amdgpuBusId = "PCI:101@0:0:0";
        };
      };

      services.cardwired = {
        enable = true;
        package = unstable.cardwire;
        settings = {
          auto_apply_gpu_state = true;
          # Nvidia blocking is still experimental in Cardwire.
          experimental_nvidia_block = true;
          # Keep Nvidia available on AC and block it on battery.
          battery_auto_switch = true;
          battery_auto_switch_mode = "integrated";
        };
      };

      services.howdy.settings.video.device_path = "/dev/video2";

      system.stateVersion = "26.05";
    };
}
