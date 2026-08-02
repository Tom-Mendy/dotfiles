{
  flake.nixosModules.common =
    { username, ... }:
    {
      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];
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

      services.printing.enable = true;
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
