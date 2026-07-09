{ inputs, ... }:
{
  flake.nixosModules.workstation =
    {
      pkgs,
      unstable,
      ...
    }:
    {
      networking.firewall = {
        enable = true;
        # 53317 localsend
        allowedTCPPorts = [ 53317 ];
        allowedUDPPorts = [ 53317 ];
      };

      programs.tmux.enable = true;
      programs.nix-ld.enable = true;

      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
      services.blueman.enable = true;

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
          policycoreutils
          bruno
          proton-vpn-cli
          rustdesk
          smartmontools
          stow
          textpieces
          tokei
          yq
          dig
          talosctl
          unzip
          # NOTE: Electron 40.10.3 and 41.7.2 have a SIGILL bug on AMD Ryzen AI 9 HX 370.
          # Not due to missing CPU features (AMD Ryzen AI 9 has AVX512, AVX2, etc.),
          # but a bug in those specific Electron versions on AMD hardware.
          # Using electron_39 which works correctly on this CPU.
          (
            (vesktop.override {
              electron_40 = pkgs.electron_39;
              withTTS = false;
            }).overrideAttrs
            {
              preBuild = ''
                cp -r ${pkgs.electron_39.dist} electron-dist
                chmod -R u+w electron-dist
              '';
            }
          )
          vim
          dav1d
          vlc
          libreoffice
          ffmpeg
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
          inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
          inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
          unstable.codex
          unstable.mistral-vibe
          unstable.opencode
          unstable.t3code
          (unstable.vscode.override {
            commandLineArgs = "--password-store=gnome-libsecret";
          })
          unstable.zed-editor
          unstable.pangolin-cli
        ];
    };
}
