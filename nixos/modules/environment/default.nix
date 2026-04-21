{ config, lib, pkgs, ... }:

let
  cfg = config.my.environment;
  minimalPackages = with pkgs; [
    git
    curl
    wget
    jq
    eza
    fd
    ripgrep
    bat
    zoxide
    fzf
    tmux
  ];
  fullPackages = with pkgs; [
    gcc
    gnumake
    cmake
    nodejs_22
    python3
    go
    rustup
    docker-compose
    kubectl
    lua-language-server
  ];
in
{
  options.my.environment = {
    enable = lib.mkEnableOption "base environment";
    profile = lib.mkOption {
      type = lib.types.enum [ "minimal" "full" ];
      default = "minimal";
      description = "Choose between a minimal and complete workstation profile.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "tmendy";
      description = "Main user receiving shell/editor home-manager configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.neovim.enable = true;

    users.users.${cfg.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" ];
      shell = pkgs.zsh;
    };

    environment.systemPackages =
      minimalPackages
      ++ lib.optionals (cfg.profile == "full") fullPackages;

    home-manager.users.${cfg.user} = { pkgs, ... }: {
      home.stateVersion = "24.11";
      programs.home-manager.enable = true;

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        shellAliases = {
          e = "nvim";
          ll = "eza -lah";
          la = "eza -a";
          ls = "eza";
          k = "kubectl";
          cat = "bat --style=plain";
        };

        initContent = ''
          export TERM="''${TERM:-xterm-256color}"
          export EDITOR=nvim
          export HISTFILE=$HOME/.zsh_history
          export HISTSIZE=10000
          export SAVEHIST=10000
          setopt INC_APPEND_HISTORY SHARE_HISTORY

          export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
          eval "$(zoxide init zsh --cmd cd)"

          bindkey '^[[1;5D' backward-word
          bindkey '^[[1;5C' forward-word
          bindkey '^[[H' beginning-of-line
          bindkey '^[[F' end-of-line
        '';
      };

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;
        withPython3 = true;

        extraPackages = with pkgs; [
          stylua
          lua-language-server
          nixd
          shfmt
          shellcheck
        ];

        plugins = with pkgs.vimPlugins; [
          lazy-nvim
          telescope-nvim
          nvim-treesitter.withAllGrammars
          which-key-nvim
          gitsigns-nvim
          vim-fugitive
          nvim-lspconfig
          conform-nvim
          nvim-lint
          undotree
          tokyonight-nvim
        ];

        extraLuaConfig = ''
          vim.g.mapleader = " "
          vim.opt.number = true
          vim.opt.relativenumber = true
          vim.opt.expandtab = true
          vim.opt.shiftwidth = 2
          vim.opt.tabstop = 2
          vim.opt.wrap = false
          vim.opt.cursorline = true
          vim.opt.termguicolors = true

          vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
          vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
          vim.keymap.set({"n", "v"}, "<leader>f", function() vim.lsp.buf.format() end)

          require("gitsigns").setup()
          require("which-key").setup()
        '';
      };
    };
  };
}
