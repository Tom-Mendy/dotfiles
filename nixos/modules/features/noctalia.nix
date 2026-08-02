{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        preInstalledPlugins.rbw.src = ./noctalia-rbw;
        settings = {
          settingsVersion = 59;

          bar = {
            position = "top";
            density = "mini";
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

          colorSchemes.useWallpaperColors = true;

          location.autoLocate = true;

          nightLight = {
            enabled = true;
            autoSchedule = true;
          };

          idle.enabled = true;

          wallpaper = {
            enabled = true;
            directory = "/home/tmendy/Pictures/Wallpapers";
            automationEnabled = false;
            linkLightAndDarkWallpapers = false;
            setWallpaperOnAllMonitors = true;
          };
        };
      };
    };
}
