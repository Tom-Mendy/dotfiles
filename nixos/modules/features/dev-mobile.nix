{
  flake.nixosModules.devMobile =
    { pkgs, ... }:
    let
      androidComposition = pkgs.androidenv.composeAndroidPackages {
        platformVersions = [ "latest" ];
        buildToolsVersions = [ "latest" ];
        includeEmulator = true;
        includeSystemImages = true;
        systemImageTypes = [ "google_apis" ];
        abiVersions = [ "x86_64" ];
        includeNDK = true;
      };
      androidSdk = androidComposition.androidsdk;
      androidHome = "${androidSdk}/libexec/android-sdk";
    in
    {
      nixpkgs.config.android_sdk.accept_license = true;

      environment.systemPackages = with pkgs; [
        androidSdk
        watchman
      ];

      environment.sessionVariables = {
        ANDROID_HOME = androidHome;
        ANDROID_SDK_ROOT = androidHome;
        ANDROID_NDK_ROOT = "${androidHome}/ndk-bundle";
      };
    };
}
