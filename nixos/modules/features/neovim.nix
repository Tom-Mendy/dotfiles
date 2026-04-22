{ self, inputs, ... }:
let
  mainModule =
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

  luaModule =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        lua-language-server
        stylua
      ];
    };

  nixModule =
    { pkgs, ... }:
    {
      extraPackages = with pkgs; [
        alejandra
        nil
        nixd
      ];
    };
in
{
  flake.modules.neovim.main = mainModule;

  flake.modules.neovim.lua = luaModule;

  flake.modules.neovim.nix = nixModule;

  flake.modules.neovim.allServers = {
    imports = [
      luaModule
      nixModule
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
          mainModule
          luaModule
          nixModule
        ];
      };

      packages.neovimFull = inputs.wrapper-modules.wrappers.neovim.wrap {
        inherit pkgs;
        dynamicMode = true;
        imports = [
          mainModule
          luaModule
          nixModule
        ];
      };
    };
}
