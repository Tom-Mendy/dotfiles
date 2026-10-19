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
      ensureBookmark = pkgs.writeShellScript "ensure-synology-bookmark" ''
        set -eu

        bookmarks="$HOME/.config/gtk-3.0/bookmarks"
        ${lib.getExe' pkgs.coreutils "mkdir"} -p "$(${lib.getExe' pkgs.coreutils "dirname"} "$bookmarks")"

        if [ -f "$bookmarks" ]; then
          ${lib.getExe pkgs.gnused} -i '\|^sftp://\(tom@\)\?\(synology\|synology-local\|10\.0\.0\.11\)/\([[:space:]].*\)\?$|d' "$bookmarks"
        fi

        if ! ${lib.getExe pkgs.gnugrep} -Fqx ${lib.escapeShellArg bookmark} "$bookmarks" 2>/dev/null; then
          printf '%s\n' ${lib.escapeShellArg bookmark} >> "$bookmarks"
        fi
      '';
    in
    {
      # The NAS uses password authentication. Offering rbw's unrelated keys
      # exhausts its authentication attempts before GVFS can ask for a password.
      programs.ssh.extraConfig = ''
        Host synology synology-local 10.0.0.11
          HostName 10.0.0.11
          User tom
          PubkeyAuthentication no
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
