{ self, inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
        settings = {
          settingsVersion = 59;

          bar = {
            position = "top";
            density = "mini";
          };

          appLauncher = {
            enableClipboardHistory = true;
            autoPasteClipboard = true;
            enableClipPreview = true;
            clipboardWatchTextCommand = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} store";
            clipboardWatchImageCommand = "${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} store";
            terminalCommand = "${lib.getExe pkgs.ghostty} -e";
          };

          wallpaper = {
            enabled = true;
            directory = "/home/tmendy/Pictures/Wallpapers";
            automationEnabled = true;
            wallpaperChangeMode = "random";
            randomIntervalSec = 86400;
            setWallpaperOnAllMonitors = true;
          };
        };
      };
    };
}
