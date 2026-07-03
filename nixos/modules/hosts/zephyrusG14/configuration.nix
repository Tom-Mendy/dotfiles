{ self, ... }:
{

  flake.nixosModules.zephyrusG14Configuration =
    { pkgs, ... }:
    {
      # import any other modules from here
      imports = [
        self.nixosModules.containers
        self.nixosModules.devCore
        self.nixosModules.devExtra
        self.nixosModules.gaming
        self.nixosModules.howdy
        self.nixosModules.kdePlasma
        self.nixosModules.zephyrusG14Hardware
        self.nixosModules.neovim
        self.nixosModules.niri
        self.nixosModules.rog
        self.nixosModules.virtualisation
        self.nixosModules.workstation
        self.nixosModules.zsh
        self.nixosModules.synologySftp
      ];

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Bootloader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Use latest kernel.
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.resumeDevice = "/dev/mapper/luks-fff3f818-7e03-48e0-ae07-a149b29524ec";
      boot.kernelParams = [ "resume_offset=84489648" ];

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        priority = 100;
      };

      boot.kernel.sysctl = {
        "vm.swappiness" = 10;
        "vm.page-cluster" = 0;
      };

      networking.hostName = "zephyrusG14"; # Define your hostname.
      # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

      # Configure network proxy if necessary
      # networking.proxy.default = "http://user:password@proxy:port/";
      # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

      # Enable networking
      networking.networkmanager.enable = true;

      # Set your time zone.
      time.timeZone = "Europe/Paris";

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "fr_FR.UTF-8";
        LC_IDENTIFICATION = "fr_FR.UTF-8";
        LC_MEASUREMENT = "fr_FR.UTF-8";
        LC_MONETARY = "fr_FR.UTF-8";
        LC_NAME = "fr_FR.UTF-8";
        LC_NUMERIC = "fr_FR.UTF-8";
        LC_PAPER = "fr_FR.UTF-8";
        LC_TELEPHONE = "fr_FR.UTF-8";
        LC_TIME = "fr_FR.UTF-8";
      };

      # Enable the X11 windowing system.
      # You can disable this if you're only using the Wayland session.
      # services.xserver.enable = true;

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      hardware.graphics.enable = true;
      services.xserver.videoDrivers = [
        "amdgpu"
        "nvidia"
      ];
      hardware.nvidia.open = true;

      hardware.nvidia.prime = {
        nvidiaBusId = "PCI:100@0:0:0";
        amdgpuBusId = "PCI:101@0:0:0";
      };

      # Configure keymap in X11
      services.xserver.xkb = {
        layout = "fr";
        variant = "";
      };

      # Configure console keymap
      console.keyMap = "fr";
      console.earlySetup = true;

      # Enable CUPS to print documents.
      services.printing.enable = true;

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      # services.xserver.libinput.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users."tmendy" = {
        isNormalUser = true;
        description = "Tom Mendy";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };

      # Install firefox.
      programs.firefox.enable = true;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      nixpkgs.config.permittedInsecurePackages = [
        "electron-39.8.10" # bitwarden-desktop & vesktop (Electron 40/41 have SIGILL bug on AMD Ryzen AI 9)
        "pnpm-10.29.2" # vesktop build dependency; pnpm 11 does not match its lockfile
      ];

      programs.git = {
        enable = true;
        lfs.enable = true;
        config = {
          user.name = "Tom Mendy";
          user.email = "tom.mendy@epitech.eu";
        };
      };

      environment.systemPackages = with pkgs; [
        bitwarden-desktop
        supersonic
        gh
        speedtest
        teams-for-linux
        veracrypt
        t3code
        jujutsu
      ];

      # Some programs need SUID wrappers, can be configured further or are
      # started in user sessions.
      # programs.mtr.enable = true;
      # programs.gnupg.agent = {
      #   enable = true;
      #   enableSSHSupport = true;
      # };

      # List services that you want to enable:

      # Enable the OpenSSH daemon.
      # services.openssh.enable = true;

      # Open ports in the firewall.
      # networking.firewall.allowedTCPPorts = [ ... ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      # networking.firewall.enable = false;

      # This value determines the NixOS release from which the default
      # settings for stateful data, like file locations and database versions
      # on your system were taken. It‘s perfectly fine and recommended to leave
      # this value at the release version of the first install of this system.
      # Before changing this value read the documentation for this option
      # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
      system.stateVersion = "26.05"; # Did you read the comment?
    };
}
