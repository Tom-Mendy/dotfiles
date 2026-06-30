{
  flake.nixosModules.howdy =
    { lib, pkgs, ... }:
    {
      # Install howdy package
      environment.systemPackages = with pkgs; [
        howdy
      ];

      # Enable and configure the howdy service
      services.howdy = {
        enable = true;
        package = pkgs.howdy;
        settings = {
          video = {
            device_path = "/dev/video2"; # video0 is webcam, video2 is IR
          };
        };
      };

      # Configure PAM to use howdy for authentication (with password fallback)
      security.pam.howdy = {
        enable = true;
        control = "sufficient";
      };
      
      # Enable howdy for login and sudo services
      security.pam.services.login.howdy.enable = true;
      security.pam.services.login.howdy.control = "sufficient";
      security.pam.services.sudo.howdy.enable = true;
      security.pam.services.sudo.howdy.control = "sufficient";

      # Add user to video group for camera access
      users.users.tmendy.extraGroups = lib.mkAfter [ "video" ];

      # Ensure polkit is enabled (needed for some display managers)
      security.polkit.enable = true;
    };
}
