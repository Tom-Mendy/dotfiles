{
  flake.nixosModules.virtualisation =
    { lib, pkgs, ... }:
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      programs.virt-manager.enable = true;
      users.users.tmendy.extraGroups = lib.mkAfter [
        "input"
        "libvirtd"
      ];

      environment.systemPackages = with pkgs; [
        qemu
        virtio-win
      ];
    };
}
