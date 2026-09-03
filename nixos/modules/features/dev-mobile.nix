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

      environment.systemPackages = with pkgs; [
        androidSdk
        nodejs_22
        watchman
      ];

      environment.sessionVariables = {
        ANDROID_HOME = androidHome;
        ANDROID_SDK_ROOT = androidHome;
        ANDROID_NDK_ROOT = "${androidHome}/ndk/${ndkVersion}";
      };

      networking.firewall.allowedTCPPorts = [
        3001 # Backend for mobile app dev
        8081 # Expo Go / Metro
      ];
    };
}
