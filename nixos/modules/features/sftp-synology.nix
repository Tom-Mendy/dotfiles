{
  flake.nixosModules.synologySftp =
    {
      config,
      lib,
      pkgs,
      username,
      ...
    }:
    let
      synologyHost = "10.0.0.11";
      synologyUser = "tom";
      shares = {
        downloads = "Downloads";
        video = "video";
        document = "Document";
        music = "music";
        home = "home";
      };
      sshfsServices = lib.mapAttrsToList (name: _: "sshfs-synology-${name}.service") shares;
      sshfsServiceList = lib.concatStringsSep " " sshfsServices;
    in
    {
      environment.systemPackages = [ pkgs.sshfs ];
      programs.fuse.userAllowOther = true;

      systemd.tmpfiles.rules = [
        "d /mnt/synology 0755 ${username} users -"
      ]
      ++ lib.mapAttrsToList (_: share: "d /mnt/synology/${share} 0755 ${username} users -") shares;

      systemd.user.services = lib.mapAttrs' (
        name: share:
        lib.nameValuePair "sshfs-synology-${name}" {
          description = "SSHFS mount for Synology ${share}";
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "simple";
            Environment = [ "SSH_AUTH_SOCK=%t/rbw/ssh-agent-socket" ];
            ExecStart = ''
              ${pkgs.sshfs}/bin/sshfs -f \
                ${synologyUser}@${synologyHost}:/${share} \
                /mnt/synology/${share} \
                -o reconnect \
                -o ServerAliveInterval=15 \
                -o ServerAliveCountMax=3 \
                -o allow_other \
                -o nodev \
                -o noatime \
                -o x-gvfs-show \
                -o "x-gvfs-name=Synology ${share}"
            '';
            ExecStop = "${pkgs.fuse3}/bin/fusermount3 -uz /mnt/synology/${share}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        }
      ) shares;

      # FUSE requests can remain blocked when the network disappears during
      # suspend. Stop the mounts before freezing user.slice and restore them
      # after resume so systemd can complete the suspend operation.
      systemd.services.sshfs-synology-sleep = {
        description = "Stop Synology SSHFS mounts before sleep";
        requiredBy = [ "sleep.target" ];
        before = [ "sleep.target" ];
        unitConfig.StopWhenUnneeded = true;
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.systemd}/bin/systemctl --user --machine=${username}@.host stop ${sshfsServiceList}";
          ExecStop = "${pkgs.systemd}/bin/systemctl --user --machine=${username}@.host start ${sshfsServiceList}";
        };
      };
    };
}
