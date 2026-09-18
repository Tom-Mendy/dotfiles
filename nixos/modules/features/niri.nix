{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      ghosttyXfceHelper = pkgs.writeTextDir "share/xfce4/helpers/ghostty.desktop" ''
        [Desktop Entry]
        Version=1.0
        Type=X-XFCE-Helper
        Name=Ghostty
        Icon=com.mitchellh.ghostty
        X-XFCE-Binaries=ghostty;
        X-XFCE-Category=TerminalEmulator
        X-XFCE-Commands=${lib.getExe pkgs.ghostty};
        X-XFCE-CommandsWithParameter=${lib.getExe pkgs.ghostty} -e "%s";
      '';
    in
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
        # Ne pas embarquer Nautilus : le FileChooser du portail GNOME ressemble
        # à un explorateur GNOME et entre en concurrence avec Thunar sur
        # org.freedesktop.FileManager1. Le portail GTK suffit sous Niri.
        useNautilus = false;
      };

      # Gestionnaire de fichiers officiel : enregistre le service D-Bus
      # org.freedesktop.FileManager1 + systemd, et active xfconf (requis
      # pour que Thunar reçoive le thème via xfsettingsd).
      programs.thunar = {
        enable = true;
        plugins = with pkgs; [ thunar-archive-plugin ];
      };

      environment.systemPackages = [
        pkgs.adw-gtk3
        pkgs.adwaita-icon-theme
        pkgs.bibata-cursors
        pkgs.gsettings-desktop-schemas
        pkgs.kdePackages.breeze-icons
        pkgs.loupe
        pkgs.thunar-volman
        pkgs.tumbler
        pkgs.xfce4-settings # fournit xfsettingsd (pont thème -> Thunar)
        ghosttyXfceHelper
        pkgs.xarchiver
        pkgs.unar
        pkgs.unrar
        pkgs.p7zip
        pkgs.seahorse
      ];

      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.gnome.gnome-keyring.enable = true;
      programs.dconf.enable = true;

      # Valeurs initiales cohérentes (Noctalia syncGsettings=true les bascule
      # ensuite à la volée via le toggle DarkMode). adw-gtk3 suit
      # color-scheme prefer-light / prefer-dark, donc Thunar (GTK3) suit le
      # thème global sans fichier settings.ini statique divergent.
      programs.dconf.profiles.user.databases = [
        {
          settings = {
            "org/gnome/desktop/interface" = {
              gtk-theme = "adw-gtk3";
              icon-theme = "Adwaita";
              cursor-theme = "Bibata-Modern-Amber";
              color-scheme = "prefer-light";
            };
          };
        }
      ];

      # Pont XSettings pour les applis GTK3/XFCE (Thunar) : sans lui, Thunar
      # ignore gsettings et reste figé sur settings.ini.
      systemd.user.services.xfsettingsd = {
        description = "XFCE settings daemon (theme bridge for Thunar)";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.xfce4-settings}/bin/xfsettingsd --daemon --replace";
          Restart = "on-failure";
        };
      };

      # Keep the login keyring unlocked when logging in through tuigreet.
      security.pam.services.greetd.enableGnomeKeyring = true;

      environment.etc."xdg/xfce4/helpers.rc".text = ''
        [Helpers]
        TerminalEmulator=ghostty
        FileManager=thunar
      '';

      xdg.mime = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "thunar.desktop";
          "x-scheme-handler/file" = "thunar.desktop";
          "image/*" = "org.gnome.Loupe.desktop";
          "application/pdf" = "org.gnome.Papers.desktop";
          "application/vnd.rar" = "xarchiver.desktop";
          "application/x-rar" = "xarchiver.desktop";
        };
      };

      xdg.portal = {
        # Le module Niri définit déjà config.niri (default gnome;gtk +
        # FileChooser=gtk quand useNautilus=false). On force juste Settings
        # sur gnome pour que le color-scheme se propage aux applis.
        config.niri."org.freedesktop.impl.portal.Settings" = "gnome";
        # Le module Niri ajoute déjà xdg-desktop-portal-gnome ; on complète
        # avec le backend GTK (FileChooser quand useNautilus=false).
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      services.greetd = {
        enable = true;
        settings.default_session = {
          command = "${lib.getExe pkgs.tuigreet} --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
          user = "greeter";
        };
      };

      security.polkit.enable = true;
      systemd.user.services.polkit-gnome-agent = {
        description = "GNOME Polkit authentication agent";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    let
      workspaceDefs = [
        {
          key = "ampersand";
          name = "1:  Terminal";
          matches = [
            { app-id = "^com\\.mitchellh\\.ghostty$"; }
          ];
        }
        {
          key = "eacute";
          name = "2:  Code";
          matches = [
            { app-id = "^(Code|code|t3code|dev\\.zed\\.Zed)$"; }
          ];
        }
        {
          key = "quotedbl";
          name = "3:  Browser";
          matches = [
            { app-id = "^(zen|helium)$"; }
          ];
        }
        {
          key = "apostrophe";
          name = "4:  Games";
          matches = [
            { app-id = "^(Steam|steam|steam_app_[0-9]+|heroic|com\\.heroicgameslauncher\\.hgl)$"; }
          ];
        }
        {
          key = "parenleft";
          name = "5:  Files";
          matches = [
            { app-id = "^(Thunar|thunar|org\\.xfce\\.Thunar)$"; }
          ];
        }
        {
          key = "minus";
          name = "6:  Documents";
          matches = [
            { app-id = "^(Logseq|libreoffice-.*)$"; }
          ];
        }
        {
          key = "egrave";
          name = "7:  Media";
          matches = [
            { app-id = "^(vlc|io\\.bassi\\.Amberol|supersonic)$"; }
            { title = "^(termusic|spotify_player)$"; }
          ];
        }
        {
          key = "underscore";
          name = "8:  Virtualization";
          matches = [
            { app-id = "^(\\.virt-manager-wrapped|virt-manager)$"; }
          ];
        }
        {
          key = "ccedilla";
          name = "9:  Chat";
          matches = [
            {
              app-id = "^(Vesktop|vesktop|teams-for-linux|signal|Element|element|karere|io\\.github\\.tobagin\\.karere|Tuta Mail)$";
            }
          ];
        }
        {
          key = "agrave";
          name = "10:  General";
          matches = [
            { app-id = "^(Pavucontrol|pavucontrol|blueman-manager|\\.blueman-manager-wrapped)$"; }
          ];
        }
      ];
      workspaceRules = map (workspace: {
        inherit (workspace) matches;
        open-on-workspace = workspace.name;
        open-focused = true;
      }) (builtins.filter (workspace: workspace ? matches) workspaceDefs);
    in
    {
      packages.myNiri =
        let
          wrappedNiri = inputs.wrapper-modules.wrappers.niri.wrap {
            inherit pkgs;
            extraSettings = map (workspace: {
              workspace = _: { props = workspace.name; };
            }) workspaceDefs;
            settings = {
              spawn-at-startup = [
                (lib.getExe self'.packages.myNoctalia)
                [
                  (lib.getExe pkgs.rbw)
                  "unlock"
                ]
              ];

              xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

              prefer-no-csd = _: { };

              cursor.xcursor-theme = "Bibata-Modern-Amber";

              window-rules = [
                { open-maximized = true; }
              ]
              ++ workspaceRules
              ++ [
                {
                  matches = [ { is-floating = true; } ];
                  border.off = _: { };
                }
              ];

              input.keyboard = {
                xkb.layout = "fr";
                numlock = true;
              };
              input.touchpad.scroll-factor = _: {
                props = {
                  vertical = 1.0;
                  horizontal = -1.0;
                };
              };
              input.touchpad.tap = _: { };
              input.touchpad.natural-scroll = _: { };

              layout = {
                gaps = 5;
                focus-ring.off = _: { };
                border = {
                  width = 2;
                  active-gradient = _: {
                    props = {
                      from = "#33ccffee";
                      to = "#00ff99ee";
                      angle = 45;
                    };
                  };
                  inactive-color = "#595959aa";
                };
                preset-column-widths = [
                  { proportion = 1.0 / 3.0; }
                  { proportion = 1.0 / 2.0; }
                  { proportion = 2.0 / 3.0; }
                ];
              };
              gestures.hot-corners.off = _: { };

              hotkey-overlay.skip-at-startup = _: { };

              binds =
                let
                  noctalia = lib.getExe self'.packages.myNoctalia;
                  whisperDictation = lib.getExe self'.packages.myWhisperDictation;
                  action = _: { };
                  workspaceBinds = builtins.listToAttrs (
                    builtins.concatMap (workspace: [
                      {
                        name = "Mod+${workspace.key}";
                        value.focus-workspace = workspace.name;
                      }
                      {
                        name = "Mod+Shift+${workspace.key}";
                        value.move-column-to-workspace = workspace.name;
                      }
                    ]) workspaceDefs
                  );
                in
                {
                  "Mod+Return".spawn-sh = "${lib.getExe pkgs.ghostty} -e herdr";
                  "Mod+E".spawn = lib.getExe pkgs.thunar;
                  "Mod+Q".close-window = _: { };
                  "Mod+S".spawn-sh = "${noctalia} ipc call launcher toggle";
                  "Mod+V".spawn-sh = "${noctalia} ipc call launcher clipboard";
                  "Mod+Shift+E".quit = action;
                  "Mod+X".spawn-sh = "${noctalia} ipc call lockScreen lock";
                  "Mod+Escape".spawn-sh = "${noctalia} ipc call sessionMenu toggle";

                  "Mod+Left".focus-column-left = action;
                  "Mod+Down".focus-window-down = action;
                  "Mod+Up".focus-window-up = action;
                  "Mod+Right".focus-column-right = action;
                  "Mod+H".focus-column-left = action;
                  "Mod+J".focus-workspace-down = action;
                  "Mod+K".focus-workspace-up = action;
                  "Mod+L".focus-column-right = action;

                  "Mod+Shift+Left".move-column-left = action;
                  "Mod+Shift+Down".move-window-down = action;
                  "Mod+Shift+Up".move-window-up = action;
                  "Mod+Shift+Right".move-column-right = action;
                  "Mod+Shift+H".move-column-left = action;
                  "Mod+Shift+J".move-window-down = action;
                  "Mod+Shift+K".move-window-up = action;
                  "Mod+Shift+L".move-column-right = action;

                  "Mod+Ctrl+Left".focus-monitor-left = action;
                  "Mod+Ctrl+Down".focus-monitor-down = action;
                  "Mod+Ctrl+Up".focus-monitor-up = action;
                  "Mod+Ctrl+Right".focus-monitor-right = action;
                  "Mod+Ctrl+H".focus-monitor-left = action;
                  "Mod+Ctrl+J".focus-monitor-down = action;
                  "Mod+Ctrl+K".focus-monitor-up = action;
                  "Mod+Ctrl+L".focus-monitor-right = action;

                  "Mod+Ctrl+Shift+Left".move-window-to-monitor-left = action;
                  "Mod+Ctrl+Shift+Down".move-window-to-monitor-down = action;
                  "Mod+Ctrl+Shift+Up".move-window-to-monitor-up = action;
                  "Mod+Ctrl+Shift+Right".move-window-to-monitor-right = action;
                  "Mod+Ctrl+Shift+H".move-window-to-monitor-left = action;
                  "Mod+Ctrl+Shift+J".move-window-to-monitor-down = action;
                  "Mod+Ctrl+Shift+K".move-window-to-monitor-up = action;
                  "Mod+Ctrl+Shift+L".move-window-to-monitor-right = action;

                  "Mod+Page_Down".focus-workspace-down = action;
                  "Mod+Page_Up".focus-workspace-up = action;
                  "Mod+Shift+Page_Down".move-column-to-workspace-down = action;
                  "Mod+Shift+Page_Up".move-column-to-workspace-up = action;

                  "Mod+R".switch-preset-column-width = action;
                  "Mod+F".maximize-column = action;
                  "Mod+Shift+F".fullscreen-window = action;
                  "Mod+Alt+F".toggle-window-floating = action;
                  "Mod+Space" = _: {
                    props.repeat = false;
                    content.spawn = whisperDictation;
                  };
                  "Mod+O".toggle-overview = action;

                  "Print".screenshot = action;
                  "Mod+Shift+S".screenshot = action;
                  "Ctrl+Shift+S".spawn-sh = "${noctalia} ipc call plugin:capture toggle";
                  "Ctrl+Print".screenshot-screen = action;
                  "Alt+Print".screenshot-window = action;

                  "XF86AudioRaiseVolume".spawn-sh = "${noctalia} ipc call volume increase";
                  "XF86AudioLowerVolume".spawn-sh = "${noctalia} ipc call volume decrease";
                  "XF86AudioMute".spawn-sh = "${noctalia} ipc call volume muteOutput";
                  "XF86AudioMicMute".spawn-sh = "${noctalia} ipc call volume muteInput";
                  "XF86MonBrightnessUp".spawn-sh = "${noctalia} ipc call brightness increase";
                  "XF86MonBrightnessDown".spawn-sh = "${noctalia} ipc call brightness decrease";
                }
                // workspaceBinds;
            };
          };
        in
        wrappedNiri.overrideAttrs (old: {
          postBuild = (old.postBuild or "") + ''
            sessionScript="$out/bin/niri-session"
            if [ -L "$sessionScript" ]; then
              sessionScriptSource="$(readlink -f "$sessionScript")"
              rm "$sessionScript"
              substitute "$sessionScriptSource" "$sessionScript" \
                --replace-fail \
                  'systemctl --user import-environment' \
                  'systemctl --user import-environment $(printenv | cut -d= -f1 | tr "\n" " ")'
              chmod +x "$sessionScript"
            fi
          '';
        });
    };
}
