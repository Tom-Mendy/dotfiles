{
  flake.nixosModules.workstationCommunication =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        karere
        signal-desktop
        teams-for-linux
        tutanota-desktop
        element-desktop
        # NOTE (Sep 2026, still true): Electron >= 40 segfaults (SIGILL/SIGTRAP)
        # on AMD Ryzen AI 9 HX 370 — Vesktop crashed 2026-09-27 on Electron
        # 43.6.0, and twice in Aug/Sep on 43.1.0 (see `coredumpctl`). Not a
        # missing-CPU-feature issue (this CPU has AVX512, AVX2, etc.).
        # No override applied: pinning electron_39 trips nixpkgs' hard
        # major-version check and would force a full local Vesktop rebuild
        # on every bump. Monitoring for now; revisit if crashes get worse.
        vesktop
      ];
    };
}
