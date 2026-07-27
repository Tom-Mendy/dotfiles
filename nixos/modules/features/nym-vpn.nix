{
  flake.nixosModules.nymVpn =
    {
      pkgs,
      lib,
      ...
    }:
    let
      nymVpnAppVersion = "2026.11.0";

      nym-vpn-app = pkgs.appimageTools.wrapType2 {
        pname = "nym-vpn-app";
        version = nymVpnAppVersion;

        src = pkgs.fetchurl {
          url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v${nymVpnAppVersion}/NymVPN_${nymVpnAppVersion}_amd64.AppImage";
          sha256 = "sha256-QWd3YpX9exi1aR+8nJ6Tcl7x3D9ZHJSYeCw8uFvPdaU=";
        };

        extraPkgs =
          pkgs: with pkgs; [
            xdg-utils
            gtk3
            glib
            webkitgtk_4_1
            libayatana-appindicator
          ];
      };

      nym-vpn-desktop = pkgs.makeDesktopItem {
        name = "nym-vpn";
        desktopName = "NymVPN";
        exec = "${nym-vpn-app}/bin/nym-vpn-app -l %U";
        terminal = false;
        type = "Application";

        categories = [
          "Network"
          "Security"
        ];

        mimeTypes = [
          "x-scheme-handler/nymvpn"
          "x-scheme-handler/nym-vpn"
        ];
      };

      nymVpnCoreVersion = "2026.11.0";

      nym-vpn-core = pkgs.stdenv.mkDerivation {
        pname = "nym-vpn-core";
        version = nymVpnCoreVersion;

        src = pkgs.fetchurl {
          url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v${nymVpnCoreVersion}/nym-vpn-core-v${nymVpnCoreVersion}_linux_x86_64.tar.gz";
          sha256 = "sha256-KaGGyc6wejfZdlF3GBiL9f1RDVd5zN+Tc48ShZRQrdY=";
        };

        sourceRoot = "nym-vpn-core-v${nymVpnCoreVersion}_linux_x86_64";

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];

        buildInputs = [
          pkgs.stdenv.cc.cc.lib
          pkgs.glibc
          pkgs.openssl
          pkgs.dbus
          pkgs.libmnl
          pkgs.libnftnl
        ];

        installPhase = ''
          mkdir -p $out/bin

          install -m755 nym-vpnd $out/bin/nym-vpnd
          install -m755 nym-vpnc $out/bin/nym-vpnc

          if [ -f nym-exclude ]; then
            install -m755 nym-exclude $out/bin/nym-exclude
          fi
        '';
      };

      nym-vpnd-polkit-policy = pkgs.writeTextFile {
        name = "nym-vpnd-polkit-policy";
        destination = "/share/polkit-1/actions/com.nymvpn.vpnd.policy";

        text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <!DOCTYPE policyconfig PUBLIC
            "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
            "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">

          <policyconfig>
            <vendor>NymVPN</vendor>
            <vendor_url>https://nym.com</vendor_url>

            <action id="com.nymvpn.vpnd.unix-access">
              <description>Access NymVPN daemon</description>

              <message>
                Authentication is required to access the NymVPN daemon
              </message>

              <defaults>
                <allow_any>auth_admin</allow_any>
                <allow_inactive>auth_admin</allow_inactive>
                <allow_active>auth_self</allow_active>
              </defaults>
            </action>
          </policyconfig>
        '';
      };
    in
    {
      environment.systemPackages = [
        nym-vpn-core
        nym-vpnd-polkit-policy
        nym-vpn-app
        nym-vpn-desktop
        pkgs.kdePackages.polkit-kde-agent-1
        pkgs.xdg-utils
      ];

      security.polkit = {
        enable = true;

        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "com.nymvpn.vpnd.unix-access" &&
                subject.user == "tmendy") {
              return polkit.Result.YES;
            }
          });
        '';
      };

      systemd.user.services.polkit-kde-agent = {
        description = "KDE Polkit authentication agent";

        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
        };
      };

      systemd.services.nym-vpnd = {
        description = "nym-vpnd daemon";

        wantedBy = [ "multi-user.target" ];
        before = [ "network-online.target" ];

        after = [
          "NetworkManager.service"
          "systemd-resolved.service"
        ];

        path = [
          pkgs.iproute2
          pkgs.iptables
          pkgs.nftables
          pkgs.coreutils
        ];

        startLimitBurst = 6;
        startLimitIntervalSec = 24;

        serviceConfig = {
          ExecStart = "${nym-vpn-core}/bin/nym-vpnd -v run-as-service";

          Restart = "always";
          RestartSec = 2;

          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_NET_BIND_SERVICE"
          ];

          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_NET_BIND_SERVICE"
          ];

          NoNewPrivileges = false;
          PrivateNetwork = false;
        };
      };

      xdg.mime.enable = true;

      xdg.mime.defaultApplications = {
        "x-scheme-handler/nymvpn" = "nym-vpn.desktop";
        "x-scheme-handler/nym-vpn" = "nym-vpn.desktop";
      };
    };
}
