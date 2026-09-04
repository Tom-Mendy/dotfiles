{
  flake.nixosModules.rbw =
    { pkgs, ... }:
    let
      rbwCopySensitive = pkgs.writeShellApplication {
        name = "rbw-copy-sensitive";
        runtimeInputs = [
          pkgs.rbw
          pkgs.wl-clipboard
        ];
        text = ''
          if [ "$#" -ne 2 ]; then
            echo "usage: rbw-copy-sensitive <password|username|otp> <entry-id>" >&2
            exit 2
          fi

          kind="$1"
          entry_id="$2"

          case "$kind" in
            password)
              rbw get "$entry_id"
              ;;
            username)
              rbw get --field username "$entry_id"
              ;;
            otp)
              rbw code "$entry_id"
              ;;
            *)
              echo "unsupported rbw field: $kind" >&2
              exit 2
              ;;
          esac | wl-copy --sensitive --trim-newline
        '';
      };
    in
    {
      environment.sessionVariables.SSH_AUTH_SOCK = "/run/user/1000/rbw/ssh-agent-socket";

      environment.systemPackages = with pkgs; [
        pinentry-gnome3
        rbw
        rbwCopySensitive
      ];
    };
}
