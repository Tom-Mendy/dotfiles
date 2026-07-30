{
  flake.nixosModules.virtualisation =
    {
      lib,
      pkgs,
      username,
      ...
    }:
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
      users.users.${username}.extraGroups = lib.mkAfter [
        "input"
        "libvirtd"
      ];

      environment.systemPackages = with pkgs; [
        qemu
        virtio-win
      ];
    };
}
