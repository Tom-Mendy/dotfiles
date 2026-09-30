{
  flake.nixosModules.common =
    { username, ... }:
    {
      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        # Download instead of building: CUDA-enabled derivations (whisper-cpp,
        # etc.) are generally NOT in cache.nixos.org but ARE in the official
        # CUDA cache. nix-community covers zen-browser, helium,
        # wrapper-modules and other community flakes.
        # NOTE: trusted-public-keys overrides the default, so the official
        # cache key must be listed explicitly.
        substituters = [
          "https://cache.nixos.org/"
          "https://cache.nixos-cuda.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        auto-optimise-store = true;
        connect-timeout = 5;
        fallback = true;
        # Your own `nix build/run/develop` calls consult the extra
        # substituters too (without this, flake nixConfig caches are ignored
        # with "you are not a trusted user" warnings).
        trusted-users = [
          "root"
          username
        ];
        # Never die mid-build with ENOSPC: CUDA + Android + kernels make for
        # a very large store. GC kicks in below 5G free until 20G is free.
        min-free = "5G";
        max-free = "20G";
      };
      nix.gc = {
        automatic = true;
        dates = "weekly";
        persistent = true;
        options = "--delete-older-than 14d";
      };

      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Paris";
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

      services.xserver.xkb.layout = "fr";
      console = {
        keyMap = "fr";
        earlySetup = true;
      };

      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Printing disabled: no printer on this laptop, and CUPS +
      # gutenprint + ghostscript is a heavy closure. Re-enable if needed.
      services.printing.enable = false;
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      users.users.${username} = {
        isNormalUser = true;
        description = "Tom Mendy";
        extraGroups = [
          "networkmanager"
          "render"
          "video"
          "wheel"
        ];
      };

      programs.appimage = {
        enable = true;
        binfmt = true;
      };

      nixpkgs.config.allowUnfree = true;

      programs.git = {
        enable = true;
        lfs.enable = true;
        config = {
          user.name = "Tom Mendy";
          user.email = "tom.mendy@epitech.eu";
          safe.directory = "/home/${username}/dotfiles";
        };
      };
    };
}
