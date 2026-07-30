{
  flake.nixosModules.howdy =
    {
      lib,
      pkgs,
      username,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        howdy
      ];

      services.howdy = {
        enable = true;
        package = pkgs.howdy;
      };

      security.pam.howdy = {
        enable = true;
        control = "sufficient";
      };

      security.pam.services.login.howdy.enable = true;
      security.pam.services.login.howdy.control = "sufficient";
      security.pam.services.sudo.howdy.enable = true;
      security.pam.services.sudo.howdy.control = "sufficient";

      users.users.${username}.extraGroups = lib.mkAfter [ "video" ];

      security.polkit.enable = true;
    };
}
