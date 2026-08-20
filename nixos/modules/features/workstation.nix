{ self, ... }:
{
  flake.nixosModules.workstation =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.workstationCli
        self.nixosModules.workstationCommunication
        self.nixosModules.workstationDesktop
        self.nixosModules.workstationDevApps
        self.nixosModules.workstationMedia
        self.nixosModules.comfyui
      ];

      networking.firewall = {
        enable = true;
        # 53317 localsend
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };

      programs.nix-ld.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      # services.blueman.enable = true;

      fonts = {
        enableDefaultPackages = true;
        packages = with pkgs; [
          font-awesome
          nerd-fonts.fira-code
          nerd-fonts.jetbrains-mono
          nerd-fonts.symbols-only
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
          open-sans
          source-han-sans
          source-han-serif
        ];
        fontconfig.defaultFonts = {
          serif = [
            "Noto Serif"
            "Source Han Serif"
          ];
          sansSerif = [
            "Open Sans"
            "Source Han Sans"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };

    };
}
