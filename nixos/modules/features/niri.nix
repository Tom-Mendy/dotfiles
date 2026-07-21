{ self, inputs, ... }:
{
  flake.nixosModules.niri =
    { pkgs, lib, ... }:
    {
      programs.niri = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };
    };

  perSystem =
    {
      pkgs,
      lib,
      self',
      ...
    }:
    {
      packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        v2-settings = true;
        settings = {
          spawn-at-startup = [
            (lib.getExe self'.packages.myNoctalia)
            (lib.getExe' pkgs.kdePackages.plasma-workspace "xembedsniproxy")
            "Keyguard"
          ];

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

          window-rules = [
            {
              matches = [ { app-id = "^com-artemchep-keyguard-MainKt$"; } ];
              open-focused = true;
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
            preset-column-widths = [
              { proportion = 1.0 / 3.0; }
              { proportion = 1.0 / 2.0; }
              { proportion = 2.0 / 3.0; }
            ];
          };
          gestures.hot-corners.off = _: { };

          binds =
            let
              noctalia = lib.getExe self'.packages.myNoctalia;
              action = _: { };
              workspaceKeys = [
                "ampersand"
                "eacute"
                "quotedbl"
                "apostrophe"
                "parenleft"
                "minus"
                "egrave"
                "underscore"
                "ccedilla"
              ];
              workspaces = builtins.listToAttrs (
                builtins.concatMap (
                  workspace:
                  let
                    key = builtins.elemAt workspaceKeys (workspace - 1);
                  in
                  [
                    {
                      name = "Mod+${key}";
                      value.focus-workspace = workspace;
                    }
                    {
                      name = "Mod+Shift+${key}";
                      value.move-column-to-workspace = workspace;
                    }
                  ]
                ) (lib.range 1 9)
              );
            in
            {
              "Mod+Return".spawn = lib.getExe pkgs.ghostty;
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
              "Mod+J".focus-window-down = action;
              "Mod+K".focus-window-up = action;
              "Mod+L".focus-column-right = action;

              "Mod+Shift+Left".move-column-left = action;
              "Mod+Shift+Down".move-window-down = action;
              "Mod+Shift+Up".move-window-up = action;
              "Mod+Shift+Right".move-column-right = action;
              "Mod+Shift+H".move-column-left = action;
              "Mod+Shift+J".move-window-down = action;
              "Mod+Shift+K".move-window-up = action;

              "Mod+Ctrl+Left".focus-monitor-left = action;
              "Mod+Ctrl+Down".focus-monitor-down = action;
              "Mod+Ctrl+Up".focus-monitor-up = action;
              "Mod+Ctrl+Right".focus-monitor-right = action;

              "Mod+Ctrl+Shift+Left".move-window-to-monitor-left = action;
              "Mod+Ctrl+Shift+Down".move-window-to-monitor-down = action;
              "Mod+Ctrl+Shift+Up".move-window-to-monitor-up = action;
              "Mod+Ctrl+Shift+Right".move-window-to-monitor-right = action;

              "Mod+Page_Down".focus-workspace-down = action;
              "Mod+Page_Up".focus-workspace-up = action;
              "Mod+Shift+Page_Down".move-column-to-workspace-down = action;
              "Mod+Shift+Page_Up".move-column-to-workspace-up = action;

              "Mod+R".switch-preset-column-width = action;
              "Mod+F".maximize-column = action;
              "Mod+Shift+F".fullscreen-window = action;
              "Mod+O".toggle-overview = action;

              "Print".screenshot = action;
              "Ctrl+Print".screenshot-screen = action;
              "Alt+Print".screenshot-window = action;

              "XF86AudioRaiseVolume".spawn-sh = "${noctalia} ipc call volume increase";
              "XF86AudioLowerVolume".spawn-sh = "${noctalia} ipc call volume decrease";
              "XF86AudioMute".spawn-sh = "${noctalia} ipc call volume muteOutput";
              "XF86AudioMicMute".spawn-sh = "${noctalia} ipc call volume muteInput";
              "XF86MonBrightnessUp".spawn-sh = "${noctalia} ipc call brightness increase";
              "XF86MonBrightnessDown".spawn-sh = "${noctalia} ipc call brightness decrease";
            }
            // workspaces;
        };
      };
    };
}
