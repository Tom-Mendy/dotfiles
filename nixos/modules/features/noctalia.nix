{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      syncGtkTheme = pkgs.writeShellApplication {
        name = "noctalia-sync-gtk-theme";
        runtimeInputs = with pkgs; [
          coreutils
          crudini
          dconf
          jq
          xfconf
        ];
        text = ''
          settingsFile="''${NOCTALIA_SETTINGS_FILE:-''${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/settings.json}"
          darkMode="''${1:-$(jq -r '.colorSchemes.darkMode // false' "$settingsFile")}"
          case "$darkMode" in
            true) theme=adw-gtk3-dark; preference=prefer-dark ;;
            false) theme=adw-gtk3; preference=prefer-light ;;
            *) echo "Invalid dark mode: $darkMode" >&2; exit 1 ;;
          esac

          dconf write /org/gnome/desktop/interface/gtk-theme "'$theme'"
          dconf write /org/gnome/desktop/interface/color-scheme "'$preference'"
          xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "$theme"

          # GTK also reads these files outside a desktop settings service.
          for version in 3.0 4.0; do
            directory="''${XDG_CONFIG_HOME:-$HOME/.config}/gtk-$version"
            mkdir -p "$directory"
            crudini --set "$directory/settings.ini" Settings gtk-theme-name "$theme"
            crudini --set "$directory/settings.ini" Settings gtk-application-prefer-dark-theme "$darkMode"
          done
        '';
      };
    in
    {
      packages.myNoctaliaGtkTheme = syncGtkTheme;
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap (
        { config, ... }:
        {
          inherit pkgs;
          # Resolve user directories at launch, including paths containing spaces.
          env.NOCTALIA_CONFIG_DIR = lib.mkForce null;
          env.NOCTALIA_SETTINGS_FILE = lib.mkForce null;
          runShell = [
            {
              name = "PREPARE_USER_CONFIG";
              data = ''
                export NOCTALIA_CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/noctalia/"
                ${pkgs.coreutils}/bin/mkdir -p "$NOCTALIA_CONFIG_DIR"
                ${pkgs.coreutils}/bin/cp -rn ${config.configPlaceholder}/. "$NOCTALIA_CONFIG_DIR"
                ${pkgs.findutils}/bin/find "$NOCTALIA_CONFIG_DIR" ! -perm -u+w -exec ${pkgs.coreutils}/bin/chmod u+w {} +
                export NOCTALIA_SETTINGS_FILE="$NOCTALIA_CONFIG_DIR/nix-settings.json"
                settings_tmp=$(${pkgs.coreutils}/bin/mktemp "$NOCTALIA_CONFIG_DIR/.nix-settings.XXXXXX")
                ${lib.getExe pkgs.jq} --arg wallpaper "$HOME/Pictures/Wallpapers" \
                  '.wallpaper.directory = $wallpaper' \
                  ${config.configPlaceholder}/settings.json > "$settings_tmp"
                ${pkgs.coreutils}/bin/mv "$settings_tmp" "$NOCTALIA_SETTINGS_FILE"
              '';
            }
          ];
          preInstalledPlugins.rbw.src = ./noctalia-rbw;
          preInstalledPlugins.capture.src = ./noctalia-capture;
          settings = {
            settingsVersion = 59;

            colorSchemes = {
              predefinedScheme = "Noctalia (default)";
              syncGsettings = true;
              useWallpaperColors = false;
            };

            hooks = {
              enabled = true;
              startup = lib.getExe syncGtkTheme;
              darkModeChange = "${lib.getExe syncGtkTheme} $1";
            };

            bar = {
              position = "top";
              density = "mini";
              screenOverrides = [
                {
                  name = "eDP-1";
                  displayMode = "auto_hide";
                }
              ];
              widgets = {
                left = [
                  { id = "Launcher"; }
                  { id = "Clock"; }
                  { id = "ActiveWindow"; }
                ];
                center = [
                  { id = "Workspace"; }
                ];
                right = [
                  { id = "Tray"; }
                  { id = "NotificationHistory"; }
                  { id = "Battery"; }
                  { id = "Volume"; }
                  { id = "Brightness"; }
                  { id = "ControlCenter"; }
                ];
              };
            };

            appLauncher = {
              position = "top_center";
              overviewLayer = true;
              viewMode = "grid";
              enableClipboardHistory = true;
              autoPasteClipboard = true;
              enableClipPreview = true;
              customLaunchPrefixEnabled = true;
              customLaunchPrefix = "${lib.getExe pkgs.app2unit} --";
              clipboardWatchTextCommand = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store";
              clipboardWatchImageCommand = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store";
              terminalCommand = "${lib.getExe pkgs.ghostty} -e";
            };

            dock.enabled = false;

            calendar.cards = [
              {
                id = "calendar-header-card";
                enabled = false;
              }
              {
                id = "calendar-month-card";
                enabled = true;
              }
              {
                id = "weather-card";
                enabled = true;
              }
            ];

            controlCenter.shortcuts.right = [
              { id = "Notifications"; }
              { id = "PowerProfile"; }
              { id = "KeepAwake"; }
              { id = "NightLight"; }
              { id = "DarkMode"; }
            ];

            controlCenter.cards = [
              {
                id = "profile-card";
                enabled = true;
              }
              {
                id = "shortcuts-card";
                enabled = true;
              }
              {
                id = "audio-card";
                enabled = true;
              }
              {
                id = "brightness-card";
                enabled = false;
              }
              {
                id = "weather-card";
                enabled = false;
              }
              {
                id = "media-sysmon-card";
                enabled = true;
              }
            ];

            location = {
              autoLocate = true;
              weatherShowEffects = false;
            };

            nightLight = {
              enabled = true;
              autoSchedule = true;
            };

            osd = {
              autoHideMs = 1000;
              backgroundOpacity = 0.5;
              location = "bottom_center";
            };

            notifications = {
              backgroundOpacity = 0.5;
              autoHideMs = 1000;
              location = "bottom_center";
            };

            idle = {
              enabled = true;
              screenOffTimeout = 300;
            };

            wallpaper = {
              enabled = true;
              automationEnabled = false;
              linkLightAndDarkWallpapers = false;
              setWallpaperOnAllMonitors = true;
            };
          };
        }
      );
    };
}
