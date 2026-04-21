{ pkgs, ... }:
{
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
}
