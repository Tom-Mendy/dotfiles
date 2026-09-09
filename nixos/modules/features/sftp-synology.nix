{
  flake.nixosModules.synologySftp =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    let
      bookmark = "sftp://tom@10.0.0.11/ Synology";
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
