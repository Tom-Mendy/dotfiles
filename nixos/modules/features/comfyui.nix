{ inputs, ... }:
{
  flake.nixosModules.comfyui =
    { pkgs, ... }:
    let
      pkgsUnstableCuda = import inputs.nixpkgs-unstable {
        system = pkgs.stdenv.hostPlatform.system;
        config = {
          allowUnfree = true;
          cudaSupport = true;
        };
      };
      comfyui = pkgsUnstableCuda.comfyui.override {
        withManager = true;
      };
    in
    {
      environment.systemPackages = [ comfyui ];

      systemd.user.services.comfyui = {
        description = "ComfyUI local image and video generation server";
        wantedBy = [ "default.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart = "${comfyui}/bin/comfyui --lowvram --base-directory %h/AI/ComfyUI --listen 127.0.0.1 --port 8188";
          Environment = [
            "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/current-system/sw/lib"
          ];
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
