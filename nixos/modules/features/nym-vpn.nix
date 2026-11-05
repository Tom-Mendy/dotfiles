{
  flake.nixosModules.nymVpn =
    {
      pkgs,
      username,
      ...
    }:
    let
      version = "2026.14.0";

      # Use NixOS GTK/WebKit instead of the AppImage's bundled graphics stack.
      nym-vpn-app = pkgs.stdenv.mkDerivation {
        pname = "nym-vpn-app";
        inherit version;

        src = pkgs.appimageTools.extractType2 {
          pname = "nym-vpn-app";
          inherit version;
          src = pkgs.fetchurl {
            url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v${version}/NymVPN_${version}_amd64.AppImage";
            sha256 = "sha256-kbuDcozWBmZUsT0zb5qEDx5vCaZndfAjlVLJE4HFcFA=";
          };
        };

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.wrapGAppsHook3
        ];
        buildInputs = with pkgs; [
          gtk3
          glib
          webkitgtk_4_1
          libsoup_3
          openssl
          dbus
          libayatana-appindicator
          stdenv.cc.cc.lib
        ];

        dontBuild = true;
        # Preserve the upstream ELF layout; invoke the Nix loader explicitly.
        dontPatchELF = true;
        dontWrapGApps = true;
        installPhase = ''
          runHook preInstall
          install -Dm755 usr/bin/nym-vpn-app $out/libexec/nym-vpn-app
          mkdir -p $out/bin
          makeWrapper ${pkgs.stdenv.cc.bintools.dynamicLinker} $out/bin/nym-vpn-app \
            --add-flags "--library-path ${pkgs.lib.makeLibraryPath [ pkgs.gtk3 pkgs.gdk-pixbuf pkgs.cairo pkgs.glib pkgs.webkitgtk_4_1 pkgs.libsoup_3 pkgs.openssl pkgs.dbus pkgs.stdenv.cc.cc.lib ]} $out/libexec/nym-vpn-app"
          mkdir -p $out/share
          cp -r usr/share/icons $out/share/
          runHook postInstall
        '';
        postFixup = ''
          gappsWrapperArgs+=(--prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils pkgs.desktop-file-utils pkgs.pciutils ]})
          wrapProgram $out/bin/nym-vpn-app "''${gappsWrapperArgs[@]}"
        '';
      };

      nym-vpn-desktop = pkgs.makeDesktopItem {
        name = "nym-vpn";
        desktopName = "NymVPN";
        exec = "${nym-vpn-app}/bin/nym-vpn-app %U";
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

      nym-vpn-core = pkgs.stdenv.mkDerivation {
        pname = "nym-vpn-core";
        inherit version;

        src = pkgs.fetchurl {
          url = "https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v${version}/nym-vpn-core-v${version}_linux_x86_64.tar.gz";
          sha256 = "sha256-6ciyQda54CBjA9OBJytCKq4jK5NLhchv5ymFLTxAGKg=";
        };

        sourceRoot = "nym-vpn-core-v${version}_linux_x86_64";

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
        pkgs.xdg-utils
      ];

      networking.firewall.checkReversePath = "loose";
      security.polkit = {
        enable = true;

        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "com.nymvpn.vpnd.unix-access" &&
                subject.user == "${username}") {
              return polkit.Result.YES;
            }
          });
        '';
      };

      systemd.services.nym-vpnd = {
        description = "nym-vpnd daemon";

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        after = [
          "network-online.target"
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
