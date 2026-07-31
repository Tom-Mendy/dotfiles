{
  flake.nixosModules.synologySftp =
    {
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
            Environment = [ "SSH_AUTH_SOCK=%t/keyguard-ssh-agent.sock" ];
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
            ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/${share}";
            Restart = "on-failure";
            RestartSec = "5s";
          };
        }
      ) shares;
    };
}
