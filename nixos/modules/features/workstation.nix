{ inputs, ... }:
{
  flake.nixosModules.workstation =
    {
      pkgs,
      master,
      unstable,
      ...
    }:
    {
      networking.firewall.enable = true;

      programs.tmux.enable = true;
      programs.nix-ld.enable = true;

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

      environment.systemPackages =
        (with pkgs; [
          alsa-lib
          atk
          blueman
          brightnessctl
          btop
          busybox
          cpu-x
          curl
          eza
          fastfetch
          file
          htop
          inxi
          iw
          killall
          localsend
          lshw
          man
          man-pages
          moreutils
          networkmanagerapplet
          ntfs3g
          numlockx
          policycoreutils
          bruno
          proton-vpn-cli
          smartmontools
          stow
          textpieces
          tokei
          unzip
          vesktop
          vim
          vlc
          volumeicon
          wget
          wirelesstools
          xclip
          xdpyinfo
          xhost
          xkill
          zip

        ])
        ++ [
          master.rustdesk
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
          inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          master.codex
          (unstable.vscode.override {
            commandLineArgs = "--password-store=gnome-libsecret";
          })
          master.zed-editor
        ];
    };
}
