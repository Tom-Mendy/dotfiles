  return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>f", group = "format/file/find" },
        { "<leader>g", group = "git" },
        { "<leader>l", group = "lint" },
        { "<leader>p", group = "project" },
        { "<leader>r", group = "replace/refactor" },
        { "<leader>t", group = "terminal" },
      },
    },
    dependencies = {
      'echasnovski/mini.nvim',
      'nvim-tree/nvim-web-devicons'
    },
  }
