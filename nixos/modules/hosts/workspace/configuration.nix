{ self, ... }:
{
  flake.nixosModules.workspaceConfiguration =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    {
      imports = [
        self.nixosModules.common
        self.nixosModules.containers
        self.nixosModules.devCore
        self.nixosModules.devExtra
        self.nixosModules.neovim
        self.nixosModules.zsh
      ];

      networking.hostName = "workspace";

      # Generic host settings: hardware filesystems and bootloader settings
      # remain deployment-specific and must be added by the target installer.
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.page-cluster" = 0;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
        priority = 100;
      };

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

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 22 ];
      };

      services.tailscale.enable = true;

      environment.systemPackages = with pkgs; [
        curl
        dig
        fastfetch
        htop
        jq
        tmux
        unzip
        wget
        zip
      ];

      system.stateVersion = "26.05";
    };
}
