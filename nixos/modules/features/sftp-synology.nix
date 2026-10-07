{
  flake.nixosModules.synologySftp =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    let
      bookmark = "sftp://synology/ Synology";
      synologyKey = pkgs.writeText "synology-ssh-key.pub" (
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGndRLmp+mIsp+K1QP8uutK+u27wdkknhRaNusnb3Rn8\n"
      );
      ensureBookmark = pkgs.writeShellScript "ensure-synology-bookmark" ''
        set -eu

        bookmarks="$HOME/.config/gtk-3.0/bookmarks"
        ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(${lib.getExe' pkgs.coreutils "dirname"} "$bookmarks")"

        if ! ${lib.getExe pkgs.gnugrep} -Fqx ${lib.escapeShellArg bookmark} "$bookmarks" 2>/dev/null; then
          printf '%s\n' ${lib.escapeShellArg bookmark} >> "$bookmarks"
        fi
      '';
    in
    {
      # GVFS uses OpenSSH for SFTP. Limit this host to the workstation key so
      # rbw's agent does not offer every loaded identity and exhaust Synology's
      # authentication attempts before reaching the right one.
      programs.ssh.extraConfig = ''
        Host synology
          HostName 10.0.0.11
          User tom
          IdentityFile ${synologyKey}
          IdentitiesOnly yes
      '';

      # A GTK bookmark is resolved by GVFS only when it is opened. Keeping the
      # NAS out of the local mount table prevents an unavailable SSH server
      # from blocking Thunar's volume discovery.
      systemd.user.services.synology-sftp-bookmark = {
        description = "Add the Synology SFTP bookmark";
        wantedBy = [ "default.target" ];
        unitConfig.ConditionUser = username;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ensureBookmark;
        };
      };
    };
}
