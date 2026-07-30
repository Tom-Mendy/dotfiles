{
  flake.nixosModules.workstationCommunication =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        karere
        signal-desktop
        teams-for-linux
        tutanota-desktop
        # NOTE: Electron 40.10.3 and 41.7.2 have a SIGILL bug on AMD Ryzen AI 9 HX 370.
        # Not due to missing CPU features (AMD Ryzen AI 9 has AVX512, AVX2, etc.),
        # but a bug in those specific Electron versions on AMD hardware.
        # Using electron_39 which works correctly on this CPU.
        vesktop
      ];
    };
}
