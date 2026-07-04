{
  flake.nixosModules.synologySftp =
    { config, pkgs, ... }:
    let
      user = "tmendy";
      home = config.users.users.${user}.home;
      # synologyHost = "nainjoueur.synology.me";
      synologyHost = "10.0.0.11";
      synologyUser = "tom";
    in
    {
      environment.systemPackages = with pkgs; [
        sshfs
      ];

      programs.fuse.userAllowOther = true;

      systemd.tmpfiles.rules = [
        "d /mnt/synology 0755 ${user} users -"
        "d /mnt/synology/Downloads 0755 ${user} users -"
        "d /mnt/synology/video 0755 ${user} users -"
        "d /mnt/synology/Document 0755 ${user} users -"
        "d /mnt/synology/music 0755 ${user} users -"
        "d /mnt/synology/home 0755 ${user} users -"
      ];

      systemd.user.services.sshfs-synology-downloads = {
        description = "SSHFS mount for Synology Downloads";

        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";

          Environment = [
            "SSH_AUTH_SOCK=${home}/.bitwarden-ssh-agent.sock"
          ];

          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              ${synologyUser}@${synologyHost}:/Downloads \
              /mnt/synology/Downloads \
              -o reconnect \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o allow_other \
              -o nodev \
              -o noatime
          '';

          ExecStop = ''
            ${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/Downloads
          '';

          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      systemd.user.services.sshfs-synology-video = {
        description = "SSHFS mount for Synology Video";

        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";

          Environment = [
            "SSH_AUTH_SOCK=${home}/.bitwarden-ssh-agent.sock"
          ];

          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              ${synologyUser}@${synologyHost}:/video \
              /mnt/synology/video \
              -o reconnect \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o allow_other \
              -o nodev \
              -o noatime
          '';

          ExecStop = ''
            ${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/video
          '';

          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      systemd.user.services.sshfs-synology-document = {
        description = "SSHFS mount for Synology Document";

        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";

          Environment = [
            "SSH_AUTH_SOCK=${home}/.bitwarden-ssh-agent.sock"
          ];

          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              ${synologyUser}@${synologyHost}:/Document \
              /mnt/synology/Document \
              -o reconnect \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o allow_other \
              -o nodev \
              -o noatime
          '';

          ExecStop = ''
            ${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/Document
          '';

          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      systemd.user.services.sshfs-synology-music = {
        description = "SSHFS mount for Synology Music";

        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";

          Environment = [
            "SSH_AUTH_SOCK=${home}/.bitwarden-ssh-agent.sock"
          ];

          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              ${synologyUser}@${synologyHost}:/music \
              /mnt/synology/music \
              -o reconnect \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o allow_other \
              -o nodev \
              -o noatime
          '';

          ExecStop = ''
            ${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/music
          '';

          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      systemd.user.services.sshfs-synology-home = {
        description = "SSHFS mount for Synology Home";

        wantedBy = [ "default.target" ];

        serviceConfig = {
          Type = "simple";

          Environment = [
            "SSH_AUTH_SOCK=${home}/.bitwarden-ssh-agent.sock"
          ];

          ExecStart = ''
            ${pkgs.sshfs}/bin/sshfs -f \
              ${synologyUser}@${synologyHost}:/home \
              /mnt/synology/home \
              -o reconnect \
              -o ServerAliveInterval=15 \
              -o ServerAliveCountMax=3 \
              -o allow_other \
              -o nodev \
              -o noatime
          '';

          ExecStop = ''
            ${pkgs.fuse3}/bin/fusermount3 -u /mnt/synology/home
          '';

          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
