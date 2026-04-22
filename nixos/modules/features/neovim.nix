{ self, inputs, ... }:
{
  flake.modules.neovim.main =
    {
      config,
      lib,
      pkgs,
      wlib,
      ...
    }:
    {
      options = {
        dynamicMode = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Use an impure config directory for fast local edits.
          '';
        };

        initLua = lib.mkOption {
          type = wlib.types.stringable;
          default = inputs.nvim-config.outPath;
        };

        dynamicInitLua = lib.mkOption {
          type = lib.types.either wlib.types.stringable lib.types.luaInline;
          default = lib.generators.mkLuaInline "vim.uv.os_homedir() .. '/dotfiles/nvim/.config/nvim'";
        };
      };

      config = {
        settings.config_directory = if config.dynamicMode then config.dynamicInitLua else config.initLua;

        extraPackages = with pkgs; [
          fd
          git
          gnumake
          ripgrep
          tree-sitter
          wl-clipboard
        ];
      };
    };

  flake.modules.neovim.lua =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        lua-language-server
        stylua
      ];
    };

  flake.modules.neovim.nix =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        alejandra
        nil
        nixd
      ];
    };

  flake.modules.neovim.allServers = {
    imports = [
      self.modules.neovim.lua
      self.modules.neovim.nix
    ];
  };

  flake.nixosModules.neovim =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.neovim
      ];

      environment.variables.EDITOR = "nvim";
    };

  perSystem =
    { pkgs, ... }:
    {
      packages.neovim = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        imports = [
          self.modules.neovim.main
          self.modules.neovim.lua
          self.modules.neovim.nix
        ];
      };

      packages.neovimFull = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        dynamicMode = true;
        imports = [
          self.modules.neovim.main
          self.modules.neovim.allServers
        ];
      };
    };
}
