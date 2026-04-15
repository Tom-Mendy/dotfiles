return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}

      vim.list_extend(opts.spec, {
        { "<leader>b", group = "buffer" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>w", group = "windows" },
      })
    end,
  },
}
