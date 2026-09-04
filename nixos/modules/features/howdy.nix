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

      security.pam.services.greetd.howdy.enable = false;

      security.pam.services.login.howdy = {
        enable = true;
        control = "sufficient";
      };

      security.pam.services.sudo.howdy = {
        enable = true;
        control = "sufficient";
      };

      security.pam.services.security.howdy = {
        enable = true;
        control = "sufficient";
      };

      users.users.${username}.extraGroups = lib.mkAfter [ "video" ];

      security.polkit.enable = true;
    };
}
