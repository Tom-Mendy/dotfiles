{
  flake.nixosModules.kdePlasma =
    { pkgs, lib, ... }:
    let
      themeAt = ''
        .data[0].Schedule.data[1].data
        | min_by(.[0] - $now | if . < 0 then -. else . end)
        | if $now >= .[1] and $now < .[3]
          then "org.kde.breeze.desktop"
          else "org.kde.breezedark.desktop"
          end
      '';
      kdeThemeSwitch = pkgs.writeShellApplication {
        name = "kde-theme-switch";
        runtimeInputs = [
          pkgs.coreutils
          pkgs.jq
          pkgs.systemd
          pkgs.kdePackages.kconfig
          pkgs.kdePackages.plasma-workspace
        ];
        text = ''
          theme_at() {
            jq --argjson now "$1" -er '${themeAt}'
          }

          if [[ "''${1-}" == --self-test ]]; then
            schedule='{"data":[{"Schedule":{"data":[null,{"data":[[1000,2000,3000,8000,9000]]}]}}]}'
            [[ "$(theme_at 1500 <<< "$schedule")" == org.kde.breezedark.desktop ]]
            [[ "$(theme_at 5000 <<< "$schedule")" == org.kde.breeze.desktop ]]
            [[ "$(theme_at 8500 <<< "$schedule")" == org.kde.breezedark.desktop ]]
            exit
          fi

          now="$(date +%s%3N)"
          theme="$(
            busctl --json=short --user call \
              org.kde.NightTime \
              /org/kde/NightTime/Manager \
              org.kde.NightTime.Manager \
              Subscribe 'a{sv}' 0 |
              theme_at "$now"
          )"
          current="$(kreadconfig6 --file kdeglobals --group KDE --key LookAndFeelPackage)"

          [[ "$current" == "$theme" ]] || plasma-apply-lookandfeel --apply "$theme"
        '';
        checkPhase = ''
          runHook preCheck
          "$target" --self-test
          runHook postCheck
        '';
      };
    in
    {
      services.displayManager.sddm.enable = true;
      services.displayManager.sddm.autoNumlock = true;
      services.desktopManager.plasma6.enable = true;

      environment.etc."xdg/kcminputrc".text = ''
        [Keyboard]
        NumLock=0
      '';
      environment.etc."xdg/kdeglobals".text = ''
        [General]
        TerminalApplication=ghostty
        TerminalService=com.mitchellh.ghostty.desktop

        [KDE]
        AutomaticLookAndFeel=false
        AutomaticLookAndFeelOnIdle=false
        DefaultLightLookAndFeel=org.kde.breeze.desktop
        DefaultDarkLookAndFeel=org.kde.breezedark.desktop
      '';
      systemd.user.services.kde-theme-switch = {
        description = "Switch KDE theme at sunrise and sunset";
        wantedBy = [ "plasma-workspace.target" ];
        partOf = [ "plasma-workspace.target" ];
        after = [ "plasma-workspace.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = lib.getExe kdeThemeSwitch;
        };
      };
      systemd.user.timers.kde-theme-switch = {
        description = "Check KDE theme every minute";
        wantedBy = [ "plasma-workspace.target" ];
        partOf = [ "plasma-workspace.target" ];
        timerConfig = {
          OnActiveSec = "1min";
          OnUnitActiveSec = "1min";
          AccuracySec = "1s";
          Unit = "kde-theme-switch.service";
        };
      };
      environment.etc."xdg/powerdevilrc".text = ''
        [AC][Display]
        LockBeforeTurnOffDisplay=false
        TurnOffDisplayIdleTimeoutSec=300
        TurnOffDisplayWhenIdle=true

        [Battery][Display]
        LockBeforeTurnOffDisplay=false
        TurnOffDisplayIdleTimeoutSec=300
        TurnOffDisplayWhenIdle=true

        [LowBattery][Display]
        LockBeforeTurnOffDisplay=false
        TurnOffDisplayIdleTimeoutSec=300
        TurnOffDisplayWhenIdle=true
      '';
      environment.etc."xdg/klipperrc".text = ''
        [General]
        KeepClipboardContents=false
        MaxClipItems=1
        IgnoreSelection=true
        SelectionTextOnly=true
        IgnoreImages=true
        URLGrabberEnabled=false
      '';
      environment.etc."xdg/kwinrc".text = ''
        [ElectricBorders]
        Top=None
        TopRight=None
        Right=None
        BottomRight=None
        Bottom=None
        BottomLeft=None
        Left=None
        TopLeft=None

        [Windows]
        ElectricBorderMaximize=false
        ElectricBorderTiling=false
      '';
      environment.etc."xdg/autostart/cliphist-text.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=cliphist text watcher
        Exec=${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type text --watch ${lib.getExe pkgs.cliphist} -max-items 750 store
        OnlyShowIn=KDE;
        X-KDE-autostart-after=panel
      '';
      environment.etc."xdg/autostart/cliphist-image.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=cliphist image watcher
        Exec=${lib.getExe' pkgs.wl-clipboard "wl-paste"} --type image --watch ${lib.getExe pkgs.cliphist} -max-items 750 store
        OnlyShowIn=KDE;
        X-KDE-autostart-after=panel
      '';

      xdg.terminal-exec = {
        enable = true;
        settings = {
          default = [ "com.mitchellh.ghostty.desktop" ];
          KDE = [ "com.mitchellh.ghostty.desktop" ];
        };
      };

      environment.systemPackages = [
        pkgs.kdePackages.dolphin
        pkgs.cliphist
        pkgs.wl-clipboard
      ];
    };
}
