{
  flake.nixosModules.devMobile =
    { pkgs, ... }:
    let
      ndkVersion = "27.1.12297006";
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ "36" ];
        buildToolsVersions = [
          "35.0.0"
          "36.0.0"
        ];
        includeEmulator = true;
        includeSystemImages = false;
        abiVersions = [
          "arm64-v8a"
          "x86_64"
        ];
        cmakeVersions = [ "3.22.1" ];
        includeNDK = true;
        ndkVersions = [ ndkVersion ];
      };
      androidSdk = androidComposition.androidsdk;
      androidHome = "${androidSdk}/libexec/android-sdk";
    in
    {
      nixpkgs.config.android_sdk.accept_license = true;

      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        # React Native DevTools is distributed as a prebuilt Linux binary and
        # expects GLib at its conventional system-library path.
        glib
      ];

      environment.systemPackages = with pkgs; [
        androidSdk
        watchman
      ];

      environment.sessionVariables = {
        ANDROID_HOME = androidHome;
        ANDROID_SDK_ROOT = androidHome;
        ANDROID_NDK_ROOT = "${androidHome}/ndk/${ndkVersion}";
      };

      networking.firewall.allowedTCPPorts = [
        3000 # Frontend for mobile app dev
        3001 # Backend for mobile app dev
        8081 # Expo Go / Metro
      ];
    };
}
