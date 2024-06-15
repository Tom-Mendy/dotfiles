# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nvimConfig = builtins.fetchTree {
    type = "github";
    owner = "Tom-Mendy";
    repo = "nvim";
  };
  dotfiles = builtins.fetchTree {
    type = "github";
    owner = "Tom-Mendy";
    repo = "dotfiles";
  };

in

{

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
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
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "fr";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tmendy = {
    isNormalUser = true;
    description = "Tom Mendy";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };
  home-manager.users.tmendy = { pkgs, ... }: {
    home.file.".config/nvim".source = "${nvimConfig}";
    home.file."dotfiles".source = "${dotfiles}";
    home.file.".zshrc".source = "${dotfiles}/zsh/.zshrc";
    home.file.".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
    home.file.".config/kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";
    /* home.file."my_scripts".source = "${dotfiles}/my_scripts/"; */

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };
  home-manager.users.root = { pkgs, ... }: {
    home.file.".config/nvim".source = nvimConfig;
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerdfonts
  ];


  # Install zsh
  programs.zsh.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # C language
    criterion
    gcc
    valgrind
    # Haskell
    ghc
    stack
    # Rust
    rustup
    # Python
    python3
    # Go
    go
    # Node
    nodejs_22
    # Lua
    lua
    # Java
    jdk
    # Container
    docker
    podman
    # Communication
    discord
    teams-for-linux
    # Editor
    vim
    vscode
    zed-editor
    # Utility
    bat
    curl
    eza
    htop
    kitty
    neofetch
    ripgrep
    safe-rm
    tmux
    vlc
    unzip
    wget
    xclip
    yazi
    zoxide
  ];

  programs.git.enable = true;

  programs.neovim.enable = true;

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
  system.stateVersion = "24.05"; # Did you read the comment?
  system.autoUpgrade.enable = true;
}

