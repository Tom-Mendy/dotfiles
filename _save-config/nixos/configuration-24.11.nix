# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
  unstableTarball =
    fetchTarball
      "https://github.com/nixos/nixpkgs/tarball/master";
  # nvimConfig = builtins.fetchGit {
  #   url = "https://github.com/Tom-Mendy/nvim.git";
  #   ref = "HEAD";
  # };
  # dotfiles = builtins.fetchGit {
  #   url = "https://github.com/Tom-Mendy/dotfiles.git";
  #   ref = "HEAD";
  # };
  tmuxTpmPlugin = builtins.fetchGit {
    url = "https://github.com/tmux-plugins/tpm";
    ref = "HEAD";
  };

  darkmode = false;
in

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "dotnet-sdk-wrapped-7.0.410"
    "dotnet-sdk-7.0.410"
    "electron-33.4.11"
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: with pkgs; {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

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

  # Enable the gnome-keyring secrets vault.
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  programs.hyprland = {
    # Install the packages from nixpkgs
    enable = true;
    # Whether to enable XWayland
    xwayland.enable = true;
    # package = pkgs.unstable.hyprland;

  };
  programs.hyprlock = {
    enable = true;
  };
  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    #  Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # Enable steam compatibility tools
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";

  };
  hardware = {
    #Opengl
    graphics.enable = true;
    # opengl.enable = true;
  };

  services.xserver.enable = true;
  services.displayManager = {
    defaultSession = "hyprland";
    # defaultSession = "none+i3";
  };

  # I3
  services.xserver = {

    desktopManager = {
      xterm.enable = false;
    };
    videoDrivers = [ "amdgpu" ]; # or "intel"

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3status
        i3lock-fancy
        source-sans-pro
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
    jack.enable = true;
    wireplumber.enable = true;

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
    shell = pkgs.nushell;
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "input" ];

  };

  home-manager.backupFileExtension = "backup";
  home-manager.users.tmendy = { pkgs, unstable, ... }: {
    programs.git = {
      enable = true;
      userName = "Tom Mendy";
      userEmail = "tom.mendy@epitech.eu";
      lfs.enable = true;
      delta.enable = true;
    };
    programs.firefox.enable = true;


    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    };


    nixpkgs.config.allowUnfree = true;
    home.packages = with pkgs; [
      # Editor
      # jetbrains.clion
      # jetbrains.goland
      libreoffice
      # logseq
      # Web Browser
      google-chrome
      tor-browser
      # Communication
      # discord
      teams-for-linux
      vesktop # discord wayland
      # ferdium
      # Game Software
      unityhub
      # Music
      rhythmbox
      # Theme
      lxappearance
      darkman
    ];

    home.file = {
      # ".config/nvim".source = "${nvimConfig}";
      # "my_scripts/".source = "${dotfiles}/my_scripts";
      # "dotfiles".source = "${dotfiles}";
      # ".zshrc".source = "${dotfiles}/zsh/.zshrc";
      # ".p10k.zsh".source = "${dotfiles}/zsh/.p10k.zsh";
      # ".config/kitty/kitty.conf".source = "${dotfiles}/kitty/kitty.conf";
      # ".bashrc".source = "${dotfiles}/bash/.bashrc";
      # "auto_wallpaper.sh".source = "${dotfiles}/auto_wallpaper.sh";
      # # i3
      # ".config/i3".source = "${dotfiles}/i3";
      # ".config/rofi".source = "${dotfiles}/rofi";
      # ".config/picom".source = "${dotfiles}/picom";
      # # Thunar
      # ".config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml".source = "${dotfiles}/Thunar/thunar.xml";
      # ".config/Thunar/uca.xml".source = "${dotfiles}/Thunar/uca.xml";
      # ".config/Thunar/accels.scm".source = "${dotfiles}/Thunar/accels.scm";
      # # Tmux
      # ".tmux/plugins/tpm".source = "${tmuxTpmPlugin}";
      # ".config/tmux/tmux.conf".source = "${dotfiles}/tmux/tmux.conf";
      # ".local/bin/tmux-sessionizer".source = "${dotfiles}/tmux/tmux-sessionizer";
      # # Hyprland
      # ".config/waybar".source = "${dotfiles}/waybar";
      # ".config/wofi".source = "${dotfiles}/wofi";
      # ".config/hypr/".source = "${dotfiles}/hypr/";
    };
    home.pointerCursor = {
      gtk.enable = true;
      # x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.arc-theme;
        name = if (darkmode) then "Arc-Dark" else "Arc";
      };

      iconTheme = {
        package = pkgs.flat-remix-icon-theme;
        name = if (darkmode) then "Flat-Remix-Blue-Dark" else "Flat-Remix-Blue-Light";
      };

      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
      };
      font = {
        name = "Sans";
        size = 11;
      };
    };

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
  };

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      font-awesome
      source-han-sans
      open-sans
      source-han-sans-japanese
      source-han-serif-japanese
      nerdfonts
    ];
    # ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Container
  virtualisation.docker = {
    enable = true;
  };

  # Kubernetes
  networking.firewall.allowedTCPPorts = [
    # 6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  # services.k3s.enable = true;
  # services.k3s.role = "server";
  # services.k3s.extraFlags = toString [
  #   "--debug" # Optionally add additional args to k3s
  # ];

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
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  programs.virt-manager.enable = true;
  # virtual box
  # virtualisation.virtualbox.host.enable = true;
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  # users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];


  programs.zsh.enable = true;
  programs.tmux.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    extest.enable = true; # Enable the Steam Experimental Client for using Steam Input on Wayland)
  };
  # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #   "steam"
  #   "steam-original"
  #   "steam-unwrapped"
  #   "steam-run"
  # ];


  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # C language
    criterion
    gdb
    gcc
    valgrind
    clang
    clang-tools
    cmake
    gnumake
    xorg.libX11
    xorg.libXrandr
    xorg.libXi
    xorg.libXcursor
    xorg.libXinerama
    xorg.libXrender
    mesa
    sfml
    # Haskell
    ghc
    stack
    # Rust
    rustup
    # Gleam
    # erlang
    # rebar3
    # gleam
    # Python
    python3
    pipenv
    python312Packages.pip
    python312Packages.fastapi
    python312Packages.python-utils
    # Go
    go
    # Node
    nodejs_22
    # Lua
    lua
    lua-language-server
    luajitPackages.luarocks
    luajitPackages.jsregexp
    # Nix
    nixpkgs-fmt
    # Java
    jdk23
    maven
    # Kotlin
    kotlin
    gradle
    # PHP
    # php83
    # php83Packages.composer
    # php83Extensions.xml
    # php83Extensions.pcov
    # php83Extensions.xdebug
    # phpunit
    # phpdocumentor
    # sqlitebrowser
    # Symfony
    # symfony-cli
    # Steam
    protonup
    # Container
    docker-compose
    docker-buildx
    cri-tools
    hadolint
    dive # look into docker image layers
    podman-tui # status of containers in the terminal
    podman-compose # start group of containers for dev
    trivy
    # Virtualisation
    virtio-win
    qemu
    k6
    # vagrant
    # Configuration management
    ansible
    ansible-lint
    python312Packages.distlib
    terraform
    # Editor
    vim
    unstable.neovim
    unstable.vscode
    # unstable.zed-editor
    # Debug-linux
    moreutils
    iw
    lshw
    busybox
    policycoreutils
    inxi
    wirelesstools
    file
    cpu-x
    putty
    ntfs3g
    smartmontools
    xorg.xdpyinfo
    pkg-config
    # latex
    ghostscript
    tetex
    texliveFull
    # texliveGUST
    # texliveMedium
    # texliveTeTeX
    codespell
    # Tmux
    python312Packages.libtmux
    sesh
    unstable.android-studio
    android-tools
    jq
    # Utility
    unstable.legcord
    unstable.spotify
    tokei
    cypress
    glibc
    glib
    atk
    pango
    cairo
    gdk-pixbuf
    gtk3
    xorg.libxshmfence
    pre-commit
    twingate
    gource
    textpieces
    bat
    nushell
    tree-sitter
    fd
    curl
    eza
    htop
    solaar
    btop
    kitty
    tree
    ghostty
    neofetch
    fastfetch
    ripgrep
    safe-rm
    vlc
    unzip
    wget
    xorg.xkill
    yazi
    zoxide
    libsForQt5.dolphin
    zip
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin
    killall
    blueman
    networkmanagerapplet # nm-applet
    volumeicon
    brightnessctl
    parcellite
    numlockx
    pavucontrol
    # rustdesk
    postman
    man
    man-pages
    # X11
    xclip
    xorg.xhost
    picom
    feh
    dunst
    flameshot
    xfce.xfce4-settings
    # Wayland
    rofi-wayland
    slurp
    cliphist
    swaylock
    grim
    wl-clipboard
    mako
    waybar
    light
    wofi
    hyprpaper
    pipewire
    wireplumber
    xdg-desktop-portal-hyprland
    libxkbcommon
    alsa-lib
    # gnucobol
    stow
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
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  boot.kernelPackages = pkgs.linuxPackages_latest;
  system.stateVersion = "25.05"; # Did you read the comment?
  system.autoUpgrade.enable = false;
  system.autoUpgrade.allowReboot = true;
}
