# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  nvimConfig = builtins.fetchGit {
    url = "https://github.com/Tom-Mendy/nvim.git";
    ref = "HEAD";
  };
  dotfiles = builtins.fetchGit {
    url = "https://github.com/Tom-Mendy/dotfiles.git";
    ref = "HEAD";
  };
  autoSetBingWallpaper = builtins.fetchGit {
    url = "https://github.com/Tom-Mendy/auto_set_bing_wallpaper.git";
    ref = "HEAD";
  };
  tmuxTpmPlugin = builtins.fetchGit {
    url = "https://github.com/tmux-plugins/tpm";
    ref = "HEAD";
  };
in 

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Tom-M-Nixos-Laptop"; # Define your hostname.
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

  # Enable I3
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 
  services.displayManager = {
    defaultSession = "none+i3";
  };
  services.xserver = {

    desktopManager = {
      xterm.enable = false;
    };
    videoDrivers = [ "amdgpu" ]; # or "intel"

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        xfce.thunar
        xfce.thunar-archive-plugin
        xfce.thunar-media-tags-plugin
        killall
        rofi
        feh
        dunst
        i3status # gives you the default i3 status bar
        blueman
        nm-tray
        pulseaudio
        volumeicon
        picom
        brightnessctl
        parcellite
        numlockx
        i3lock-fancy
        xss-lock
      ];
    };
  };

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
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tmendy = {
    isNormalUser = true;
    description = "Tom Mendy";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  home-manager.users.tmendy = { pkgs, ... }: {
    home.file.".config/nvim".source = "${nvimConfig}";
    home.file."my_scripts/".source = "${dotfiles}/my_scripts";
    home.file."dotfiles".source = "${dotfiles}";
    home.file.".zshrc".source = "${dotfiles}/zsh/.zshrc";
    home.file.".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
    home.file.".config/kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";
    home.file.".bashrc".source = "${dotfiles}/bash/.bashrc";
    # i3
    home.file.".config/i3".source = "${dotfiles}/i3";
    home.file.".config/rofi".source = "${dotfiles}/rofi";
    home.file.".config/picom".source = "${dotfiles}/picom";
    home.file.".gtkrc-2.0".source = "${dotfiles}/gtk-3.0/.gtkrc-2.0";
    home.file.".config/gtk-3.0/settings.ini".source = "${dotfiles}/gtk-3.0/settings.ini";
    home.file.".icons/default/index.theme".source = "${dotfiles}/icons/default/index.theme";
    home.file."auto_set_bing_wallpaper/".source = "${autoSetBingWallpaper}";
    # Thunar
    home.file.".config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml".source = "${dotfiles}/Thunar/thunar.xml";
    home.file.".config/Thunar/uca.xml".source = "${dotfiles}/Thunar/uca.xml";
    home.file.".config/Thunar/accels.scm".source = "${dotfiles}/Thunar/accels.scm";
    # Tmux
    home.file.".tmux/plugins/tpm".source = "${tmuxTpmPlugin}";
    home.file.".config/tmux/tmux.conf".source = "${dotfiles}/tmux/tmux.conf";
    home.file.".local/bin/tmux-sessionizer".source = "${dotfiles}/tmux/tmux-sessionizer";

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };
  home-manager.users.root = { pkgs, ... }: {
    home.file.".config/nvim".source = "${nvimConfig}";
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # Container
  virtualisation.docker = {
    enable = true;
  };

  # Virtualisation
  # virt-manager
  virtualisation.libvirtd = {
  enable = true;
  qemu = {
    package = pkgs.qemu_kvm;
    runAsRoot = true;
    swtpm.enable = true;
    ovmf = {
      enable = true;
      packages = [(pkgs.OVMF.override {
        secureBoot = true;
        tpmSupport = true;
      }).fd];
    };
  };
};
  programs.virt-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  programs.firefox.enable = true;
  programs.git.enable = true;
  programs.tmux.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };


  environment.variables.EDITOR = "nvim";
  environment.variables. BROWSER = "firefox";
  environment.variables.TERMINAL = "kitty";

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    # PHP
    php
    php83Packages.composer
    sqlitebrowser
    # Container
    docker-compose
    cri-tools
    # Virtualisation
    virtio-win
    qemu
    # Communication
    discord
    teams-for-linux
    # Editor
    vim
    vscode
    zed-editor
    # Theme
    lxappearance
    arc-theme
    flat-remix-icon-theme
    bibata-cursors
    darkman
    # Debug-linux
    iw
    lshw
    busybox
    policycoreutils
    inxi
    wirelesstools
    # Tmux
    sesh
    # Web Browser
    ladybird
    google-chrome
    tor-browser
    # Utility
    logseq
    rhythmbox
    bat
    curl
    eza
    htop
    kitty
    neofetch
    ripgrep
    safe-rm
    vlc
    unzip
    wget
    xclip
    xorg.xkill
    yazi
    zoxide
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
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "24.05"; # Did you read the comment?
  system.autoUpgrade.enable = true;
}
