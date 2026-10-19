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
          type = lib.types.either wlib.types.stringable lib.types.luaInline;
          default = lib.generators.mkLuaInline "vim.fn.stdpath('config')";
        };

        dynamicInitLua = lib.mkOption {
          type = lib.types.either wlib.types.stringable lib.types.luaInline;
          default = config.initLua;
        };
      };

      config = {
        settings.config_directory = if config.dynamicMode then config.dynamicInitLua else config.initLua;

        runtimePkgs = with pkgs; [
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
      runtimePkgs = with pkgs; [
        lua-language-server
        stylua
      ];
    };

  nixModule =
    { pkgs, ... }:
    {
      runtimePkgs = with pkgs; [
        alejandra
        nil
        nixd
      ];
    };
in
{
  flake.nixosModules.neovim =
    { pkgs, ... }:
    let
      neovim = self.packages.${pkgs.stdenv.hostPlatform.system}.neovim;
    in
    {
      environment.systemPackages = [ neovim ];

      environment.variables = {
        EDITOR = "${neovim}/bin/nvim";
        VISUAL = "${neovim}/bin/nvim";
      };
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
