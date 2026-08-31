{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap (
        { config, ... }:
        {
          inherit pkgs;
          # Keep runtime-generated colors and downloaded plugins writable.
          outOfStoreConfig = "/home/tmendy/.config/noctalia";
          # Keep the main settings declarative while allowing theme changes at runtime.
          env.NOCTALIA_SETTINGS_FILE = "${config.configPlaceholder}/settings.json";
          preInstalledPlugins.rbw.src = ./noctalia-rbw;
          settings = {
            settingsVersion = 59;

            colorSchemes = {
              predefinedScheme = "Noctalia (default)";
              syncGsettings = true;
              useWallpaperColors = false;
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
              location = "bottom_center";
            };

            idle = {
              enabled = true;
              screenOffTimeout = 300;
            };

            wallpaper = {
              enabled = true;
              directory = "/home/tmendy/Pictures/Wallpapers";
              automationEnabled = false;
              linkLightAndDarkWallpapers = false;
              setWallpaperOnAllMonitors = true;
            };
          };
        }
      );
    };
}
